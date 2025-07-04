import QtQuick
import Quickshell
import Quickshell.Io
import "root:/core"

CustomRect {
    color: Colors.surface
    anchors.fill: parent

    bottomLeftRadius: 10
    bottomRightRadius: 10
    topLeftRadius: 10
    topRightRadius: 10

    MouseArea {
        id: powerMenuArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            visibilities.powerMenu = true;
        }
        onExited: {
            visibilities.powerMenu = false;
        }
    }

    MaterialIcon {
        id: restartIcon
        text: "restart_alt"
        font.pixelSize: Fonts.sizing.large
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: powerIcon.top
            margins: Sizing.margins.medium
        }
    }

    MaterialIcon {
        id: powerIcon
        text: "power_settings_new"
        font.pixelSize: Fonts.sizing.large
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: Sizing.margins.medium
        }
    }

    MouseArea {
        anchors.fill: restartIcon
        onClicked: {
            reboot.running = true;
        }
    }

    MouseArea {
        anchors.fill: powerIcon
        onClicked: {
            powerOff.running = true;
        }
    }

    Process {
        id: powerOff
        running: false
        command: "poweroff"
    }

    Process {
        id: reboot
        running: false
        command: "reboot"
    }
}
