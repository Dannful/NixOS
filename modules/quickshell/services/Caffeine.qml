pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Caffeine is ON when hypridle is NOT running
    property bool active: false

    function toggle() {
        if (root.active) {
            // Caffeine is on, turn it off by starting hypridle
            startHypridle.running = true;
        } else {
            // Caffeine is off, turn it on by stopping hypridle
            stopHypridle.running = true;
        }
    }

    // Check status once on startup
    Component.onCompleted: checkStatus.running = true

    // Monitor D-Bus for hypridle state changes (runs continuously)
    Process {
        id: monitor
        command: [
            "busctl", "--user", "--json=short", "monitor",
            "--match", "type=signal,sender=org.freedesktop.systemd1,path=/org/freedesktop/systemd1/unit/hypridle_2eservice,interface=org.freedesktop.DBus.Properties,member=PropertiesChanged"
        ]
        running: true

        stdout: SplitParser {
            onRead: data => {
                // When we receive a PropertiesChanged signal, check the new state
                if (data.includes("PropertiesChanged")) {
                    checkStatus.running = true;
                }
            }
        }
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
