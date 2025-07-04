pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property alias reboot: reboot
    property alias powerOff: powerOff

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
}
