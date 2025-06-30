import QtQuick.Controls
import QtQuick
import Quickshell
import "root:/core"
import "root:/bar/components"

Item {
    id: root
    required property PersistentProperties visibilities

    MouseArea {
        hoverEnabled: true

        anchors.fill: icon

        onEntered: {
            visibilities.powerMenu = true;
        }

        onExited: {
            visibilities.powerMenu = powerMenuArea.containsMouse;
        }
    }

    MouseArea {
        id: powerMenuArea
        hoverEnabled: true

        x: icon.x + icon.implicitWidth
        y: icon.y
        implicitWidth: root.parent.implicitWidth
        implicitHeight: icon.implicitHeight

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
        }
    }
}
