pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Caffeine is ON when hypridle is NOT running
    property bool active: false

    function toggle() {
        root.active = !root.active;
        if (root.active) {
            stopHypridle.running = true;
        } else {
            startHypridle.running = true;
        }
    }

    // Check status once at startup
    Timer {
        interval: 0
        running: true
        onTriggered: checkStatus.running = true
    }

    Process {
        id: checkStatus
        command: ["systemctl", "--user", "is-active", "hypridle.service"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const status = data.trim();
                // active = hypridle is NOT running (inactive/failed/etc)
                root.active = status !== "active";
            }
        }
    }

    Process {
        id: startHypridle
        command: ["systemctl", "--user", "start", "hypridle.service"]
        running: false
        onRunningChanged: {
            if (!running) {
                checkStatus.running = true;
            }
        }
    }

    Process {
        id: stopHypridle
        command: ["systemctl", "--user", "stop", "hypridle.service"]
        running: false
        onRunningChanged: {
            if (!running) {
                checkStatus.running = true;
            }
        }
    }
}
