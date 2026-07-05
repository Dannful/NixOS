pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property alias reboot: reboot
    property alias powerOff: powerOff
    property alias lock: lock
    property real memoryUsage: 0
    property real cpuUsage: 0
    property string time: ""
    property real prevIdle: 0
    property real prevTotal: 0
    property real _memTotal: 0
    property var perCoreUsage: []
    property var disks: []
    property var _corePrevIdle: ({})
    property var _corePrevTotal: ({})

    Process {
        id: lock
        command: "hyprlock"
        running: false
    }

    Process {
        id: reboot
        command: "reboot"
        running: false
    }

    Process {
        id: powerOff
        command: "poweroff"
        running: false
    }

    Process {
        id: monitor
        running: true
        command: ["bash", "-c", "d=$(mktemp -d); mkfifo \"$d/p\"; exec 3<>\"$d/p\"; rm -rf \"$d\"; while true; do grep '^cpu' /proc/stat; while IFS= read -r l; do case $l in MemTotal:*|MemAvailable:*) echo \"$l\";; esac; done </proc/meminfo; read -rt3 <&3 || true; done"]
        stdout: SplitParser {
            onRead: line => {
                if (line.startsWith("cpu ")) {
                    const parts = line.trim().split(/\s+/);
                    if (parts.length < 6) return;
                    const idle = parseInt(parts[4]) + parseInt(parts[5]);
                    const total = parts.slice(1).reduce((s, v) => s + parseInt(v), 0);
                    const deltaIdle = idle - root.prevIdle;
                    const deltaTotal = total - root.prevTotal;
                    root.cpuUsage = deltaTotal > 0 ? (1 - deltaIdle / deltaTotal) : 0;
                    root.prevIdle = idle;
                    root.prevTotal = total;
                } else if (/^cpu\d+/.test(line)) {
                    const parts = line.trim().split(/\s+/);
                    if (parts.length < 6) return;
                    const core = parts[0].slice(3);
                    const idle = parseInt(parts[4]) + parseInt(parts[5]);
                    const total = parts.slice(1).reduce((s, v) => s + parseInt(v), 0);
                    const prevIdle = root._corePrevIdle[core] || 0;
                    const prevTotal = root._corePrevTotal[core] || 0;
                    const deltaIdle = idle - prevIdle;
                    const deltaTotal = total - prevTotal;
                    const usage = deltaTotal > 0 ? (1 - deltaIdle / deltaTotal) : 0;
                    root._corePrevIdle[core] = idle;
                    root._corePrevTotal[core] = total;
                    const next = root.perCoreUsage.slice();
                    next[parseInt(core)] = usage;
                    root.perCoreUsage = next;
                } else if (line.startsWith("MemTotal:")) {
                    const m = line.match(/(\d+)/);
                    if (m) root._memTotal = parseInt(m[1]);
                } else if (line.startsWith("MemAvailable:") && root._memTotal > 0) {
                    const m = line.match(/(\d+)/);
                    if (m) root.memoryUsage = (root._memTotal - parseInt(m[1])) / root._memTotal;
                }
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            diskUsage.running = false;
            diskUsage.running = true;
        }
    }

    Process {
        id: diskUsage
        running: false
        command: ["bash", "-c", "df -B1 --output=target,pcent,used,size -x tmpfs -x devtmpfs -x overlay -x squashfs 2>/dev/null | tail -n +2"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n").filter(l => l.length > 0);
                const seen = {};
                const result = [];
                for (const line of lines) {
                    const parts = line.trim().split(/\s+/);
                    if (parts.length < 4) continue;
                    const mount = parts[0];
                    if (seen[mount]) continue;
                    seen[mount] = true;
                    const pcent = parseInt(parts[1]) || 0;
                    const used = parseFloat(parts[2]) || 0;
                    const size = parseFloat(parts[3]) || 0;
                    result.push({ mount: mount, usedFraction: pcent / 100, usedBytes: used, totalBytes: size });
                }
                root.disks = result;
            }
        }
    }
}
