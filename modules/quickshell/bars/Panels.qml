import Quickshell
import QtQuick
import "root:/bars/left/components/power_menu" as PowerMenu
import "root:/bars/left/components/network_menu" as NetworkMenu
import "root:/core"

Item {
    id: root
    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property Item bar
    anchors.fill: parent

    PowerMenu.Wrapper {
        screen: root.screen
        visibility: root.visibilities.powerMenu
        x: bar.getX(bar.powerIcon)
        y: bar.getY(this, bar.powerIcon)
    }

    NetworkMenu.Wrapper {
        screen: root.screen
        visibility: root.visibilities.networkMenu
        x: bar.getX(bar.networkIcon)
        y: bar.getY(this, bar.networkIcon)
    }
}
