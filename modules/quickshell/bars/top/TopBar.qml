import QtQuick
import QtQuick.Layouts
import Quickshell

import "root:/core"
import "root:/services"
import "root:/bars/top/components/tray" as SystemTray

CustomRect {
    required property ShellScreen screen
    required property PersistentProperties visibilities

    color: Colors.surface
    radius: Sizing.radius.medium
    border.color: Colors.darkSurface
    border.width: 1

    implicitHeight: Sizing.topBarHeight

    property alias timeText: timeText

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

    SystemTray.Content {
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: Sizing.spacing.small
        }
    }
}
