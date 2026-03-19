import QtQuick
import QtQuick.Layouts
import Quickshell

import "root:/core"
import "root:/services"

Item {
    id: root
    required property ShellScreen screen

    // Position at top right, below the top bar
    anchors {
        top: parent.top
        right: parent.right
        topMargin: Sizing.topBarHeight + Sizing.margins.medium
        rightMargin: Sizing.margins.medium
    }

    // Only take up space when there are notifications
    readonly property bool hasNotifications: notificationColumn.implicitHeight > 0
    implicitWidth: hasNotifications ? 380 : 0
    implicitHeight: notificationColumn.implicitHeight

    // Clip to hide sliding notifications
    clip: true

    ColumnLayout {
        id: notificationColumn
        anchors {
            top: parent.top
            right: parent.right
        }
        width: parent.width
        spacing: Sizing.margins.small

        Repeater {
            model: Notifications.notifications

            NotificationPopup {
                required property var modelData
                notification: modelData
                Layout.fillWidth: true
            }
        }
    }
}
