import Quickshell
import QtQuick
import "root:/bar/components/power_menu" as PowerMenu

Item {
    id: root
    required property ShellScreen screen
    required property PersistentProperties visibilities
    anchors.fill: parent

    PowerMenu.Wrapper {
        screen: root.screen
        visibility: root.visibilities.powerMenu
        x: 60
        y: screen.height - height - 30
        implicitWidth: 60
        implicitHeight: 180
    }
}
