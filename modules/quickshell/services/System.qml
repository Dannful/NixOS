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
        command: ["bash", "-c", "d=$(mktemp -d); mkfifo \"$d/p\"; exec 3<>\"$d/p\"; rm -rf \"$d\"; while true; do IFS= read -r l </proc/stat; echo \"$l\"; while IFS= read -r l; do case $l in MemTotal:*|MemAvailable:*) echo \"$l\";; esac; done </proc/meminfo; read -rt3 <&3 || true; done"]
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
}
