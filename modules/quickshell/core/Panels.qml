import Quickshell
import QtQuick
import "root:/bar/components/power_menu" as PowerMenu
import "root:/bar/components/network_menu" as NetworkMenu

Item {
    id: root
    required property ShellScreen screen
    required property PersistentProperties visibilities
    anchors.fill: parent

    PowerMenu.Wrapper {
        screen: root.screen
        visibility: root.visibilities.powerMenu
        x: 60
        y: screen.height - implicitHeight - Fonts.sizing.large
    }

    NetworkMenu.Wrapper {
        screen: root.screen
        visibility: root.visibilities.networkMenu
        x: 60
        y: screen.height - implicitHeight - Fonts.sizing.large * 7 / 2
    }
}
