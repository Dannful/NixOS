import Quickshell
import QtQuick
import "root:/bars/left/components/power_menu" as PowerMenu
import "root:/bars/left/components/network_menu" as NetworkMenu
import "root:/bars/top/components/calendar" as Calendar
import "root:/core"

Item {
    id: root
    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property Item leftBar
    required property Item topBar
    anchors.fill: parent

    Calendar.Wrapper {
        screen: root.screen
        visibility: root.visibilities.calendar
        triggerItem: topBar.timeText
        onRequestClose: root.visibilities.calendar = false
        x: topBar.timeText.x - implicitWidth / 2
        y: topBar.timeText.y + topBar.implicitHeight / 2
    }

    PowerMenu.Wrapper {
        screen: root.screen
        visibility: root.visibilities.powerMenu
        triggerItem: leftBar.powerIcon
        onRequestClose: root.visibilities.powerMenu = false
        x: leftBar.getX(leftBar.powerIcon)
        y: leftBar.getY(this, leftBar.powerIcon)
    }

    NetworkMenu.Wrapper {
        screen: root.screen
        visibility: root.visibilities.networkMenu
        triggerItem: leftBar.networkIcon
        onRequestClose: root.visibilities.networkMenu = false
        x: leftBar.getX(leftBar.networkIcon)
        y: leftBar.getY(this, leftBar.networkIcon)
    }
}
