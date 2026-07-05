import Quickshell
import QtQuick
import "root:/bars/left/components/power_menu" as PowerMenu
import "root:/bars/left/components/network_menu" as NetworkMenu
import "root:/bars/left/components/display_menu" as DisplayMenu
import "root:/bars/top/components/calendar" as Calendar
import "root:/bars/top/components/netspeed" as NetSpeedWidget
import "root:/bars/top/components/weather" as WeatherWidget
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
        // Center horizontally under the time text, but keep within screen bounds
        x: Math.max(Sizing.margins.small, Math.min(
            topBar.timeText.x + topBar.timeText.width / 2 - implicitWidth / 2,
            root.screen.width - implicitWidth - Sizing.margins.small
        ))
        // Position directly below the top bar (no gap)
        y: Sizing.topBarHeight + Sizing.margins.small
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

    DisplayMenu.Wrapper {
        screen: root.screen
        visibility: root.visibilities.displayMenu
        triggerItem: leftBar.displayIcon
        onRequestClose: root.visibilities.displayMenu = false
        x: leftBar.getX(leftBar.displayIcon)
        y: leftBar.getY(this, leftBar.displayIcon)
    }

    NetSpeedWidget.Wrapper {
        screen: root.screen
        visibility: root.visibilities.netSpeed
        triggerItem: topBar.netSpeedChip
        onRequestClose: root.visibilities.netSpeed = false
        readonly property real chipCenterX: topBar.netSpeedChip.mapToItem(topBar, 0, 0).x + topBar.netSpeedChip.width / 2
        x: Math.max(Sizing.margins.small, Math.min(
            chipCenterX - implicitWidth / 2,
            root.screen.width - implicitWidth - Sizing.margins.small
        ))
        y: Sizing.topBarHeight + Sizing.margins.small
    }

    WeatherWidget.Wrapper {
        screen: root.screen
        visibility: root.visibilities.weather
        triggerItem: topBar.weatherChip
        onRequestClose: root.visibilities.weather = false
        readonly property real chipCenterX: topBar.weatherChip.mapToItem(topBar, 0, 0).x + topBar.weatherChip.width / 2
        x: Math.max(Sizing.margins.small, Math.min(
            chipCenterX - implicitWidth / 2,
            root.screen.width - implicitWidth - Sizing.margins.small
        ))
        y: Sizing.topBarHeight + Sizing.margins.small
    }
}
