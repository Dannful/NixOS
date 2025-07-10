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

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            memory.running = true;
            cpu.running = true;
        }
    }

    Process {
        id: memory
        command: ["free"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const numbersRegex = /(\d+)/g;
                const matches = text.match(numbersRegex);
                if (matches.length >= 2) {
                    const totalMemory = parseInt(matches[0]);
                    const usedMemory = parseInt(matches[1]);
                    root.memoryUsage = usedMemory / totalMemory;
                }
            }
        }
    }

    Process {
        id: cpu
        command: ["vmstat", "1", "2"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length === 0)
                    return;
                const last = lines[lines.length - 1].trim();
                const numbersRegex = /(\d+)/g;
                const matches = last.match(numbersRegex);
                if (matches.length < 15)
                    return;
                const idleTime = parseInt(matches[14]);
                root.cpuUsage = (100 - idleTime) / 100;
            }
        }
    }
}
