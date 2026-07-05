import QtQuick
import QtQuick.Layouts
import Quickshell
import "root:/core"
import "root:/services"

Item {
    id: root
    required property PersistentProperties visibilities
    visible: Weather.available

    property alias containsMouse: hoverHandler.hovered

    implicitWidth: visible ? layout.implicitWidth : 0
    implicitHeight: visible ? layout.implicitHeight : 0

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        onTapped: root.visibilities.weather = !root.visibilities.weather
    }

    RowLayout {
        id: layout
        anchors.verticalCenter: parent.verticalCenter
        spacing: Sizing.spacing.minimal

        MaterialIcon {
            name: Weather.currentIcon
            size: Fonts.sizing.medium * 1.2
            color: root.containsMouse || root.visibilities.weather ? Colors.primary : Colors.foreground
        }

        CustomText {
            text: Math.round(Weather.currentTemp) + "°"
            font.pixelSize: Fonts.sizing.medium
            color: root.containsMouse || root.visibilities.weather ? Colors.primary : Colors.foreground
            animationTarget: ""
        }
    }
}
