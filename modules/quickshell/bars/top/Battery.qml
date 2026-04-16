import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "root:/core"

Item {
    property var battery: UPower.displayDevice
    visible: battery && battery.isPresent

    implicitWidth: visible ? batteryText.implicitWidth : 0
    implicitHeight: visible ? batteryText.implicitHeight : 0

    CustomText {
        id: batteryText
        anchors.centerIn: parent
        font.family: "FiraCode Nerd Font Mono"
        font.pixelSize: Fonts.sizing.medium
        text: {
            if (!battery) return ""
            const rawPercentage = battery.percentage
            const percentage = Math.round(rawPercentage <= 1 ? rawPercentage * 100 : rawPercentage)
            const charging = battery.state === UPowerDevice.Charging
            const icon = charging ? "󰂄" : parent.getBatteryIcon(percentage)
            return `${icon} ${percentage}%`
        }
        color: parent.getBatteryColor()
        animationTarget: ""
    }

    function getBatteryIcon(percentage) {
        if (percentage >= 90) return "󰁹"
        if (percentage >= 80) return "󰂂"
        if (percentage >= 70) return "󰂁"
        if (percentage >= 60) return "󰂀"
        if (percentage >= 50) return "󰁿"
        if (percentage >= 40) return "󰁾"
        if (percentage >= 30) return "󰁽"
        if (percentage >= 20) return "󰁼"
        if (percentage >= 10) return "󰁻"
        return "󰁺"
    }

    function getBatteryColor() {
        if (!battery) return Colors.foreground
        const rawPercentage = battery.percentage
        const percentage = rawPercentage <= 1 ? rawPercentage * 100 : rawPercentage
        const charging = battery.state === UPowerDevice.Charging

        if (charging) return Colors.primary
        if (percentage <= 20) return Colors.error
        if (percentage <= 40) return Colors.warning
        return Colors.success
    }
}
