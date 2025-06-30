import QtQuick
import Quickshell
import Quickshell.Io
import "root:/core"

CustomRect {
    color: "#fff"
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
        id: icon
        text: "power_settings_new"
        font.pixelSize: 24
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            margins: 21
        }
    }

    MouseArea {
        anchors.fill: icon
        onClicked: {
            powerOff.running = true;
        }
    }

    Process {
        id: powerOff
        running: false
        command: "poweroff"
    }
}
