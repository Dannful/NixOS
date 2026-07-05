import QtQuick
import QtQuick.Layouts
import Quickshell

import "root:/core"
import "root:/services"
import "root:/bars/top/components/tray" as SystemTray
import "root:/bars/top/components/netspeed" as NetSpeedWidget
import "root:/bars/top/components/weather" as WeatherWidget

CustomRect {
    id: root
    required property ShellScreen screen
    required property PersistentProperties visibilities

    color: Colors.surface
    radius: Sizing.radius.medium
    border.color: Colors.darkSurface
    border.width: 1

    implicitHeight: Sizing.topBarHeight

    property alias timeText: timeText
    property alias netSpeedChip: netSpeedChip
    property alias weatherChip: weatherChip

    Workspaces {
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: Sizing.spacing.small
        }
    }

    Date {
        id: timeText
        visibilities: parent.visibilities
        anchors.centerIn: parent
    }

    RowLayout {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: Sizing.spacing.small
        }
        spacing: Sizing.spacing.medium

        WeatherWidget.Content {
            id: weatherChip
            visibilities: root.visibilities
            Layout.alignment: Qt.AlignVCenter
        }

        NetSpeedWidget.Content {
            id: netSpeedChip
            visibilities: root.visibilities
            Layout.alignment: Qt.AlignVCenter
        }

        Battery {
            Layout.alignment: Qt.AlignVCenter
        }

        SystemTray.Content {
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
