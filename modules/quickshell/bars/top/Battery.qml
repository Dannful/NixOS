import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import "root:/core"

Item {
    property var battery: UPower.displayDevice
    visible: battery && battery.isPresent

    property real percentage: {
        if (!battery) return 0
        const raw = battery.percentage
        return raw <= 1 ? raw * 100 : raw
    }

    property bool charging: battery && battery.state === UPowerDevice.Charging

    implicitWidth: visible ? layout.implicitWidth : 0
    implicitHeight: visible ? layout.implicitHeight : 0

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: Sizing.spacing.minimal

        MaterialIcon {
            name: parent.parent.getBatteryIcon()
            size: Fonts.sizing.medium * 1.2
            color: parent.parent.getBatteryColor()
        }

        CustomText {
            text: `${Math.round(parent.parent.percentage)}%`
            font.pixelSize: Fonts.sizing.medium
            color: parent.parent.getBatteryColor()
            animationTarget: ""
        }
    }

    function getBatteryIcon() {
        if (charging) {
            if (percentage >= 95) return "battery_charging_full"
            if (percentage >= 85) return "battery_charging_90"
            if (percentage >= 75) return "battery_charging_80"
            if (percentage >= 65) return "battery_charging_60"
            if (percentage >= 45) return "battery_charging_50"
            if (percentage >= 35) return "battery_charging_30"
            return "battery_charging_20"
        }

        if (percentage >= 95) return "battery_full"
        if (percentage >= 85) return "battery_6_bar"
        if (percentage >= 70) return "battery_5_bar"
        if (percentage >= 55) return "battery_4_bar"
        if (percentage >= 40) return "battery_3_bar"
        if (percentage >= 25) return "battery_2_bar"
        if (percentage >= 10) return "battery_1_bar"
        return "battery_alert"
    }

    function getBatteryColor() {
        if (!battery) return Colors.foreground
        if (charging) return Colors.primary
        if (percentage <= 20) return Colors.error
        if (percentage <= 40) return Colors.warning
        return Colors.success
    }
}
