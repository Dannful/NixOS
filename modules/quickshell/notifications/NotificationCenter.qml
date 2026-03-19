import QtQuick
import QtQuick.Layouts
import Quickshell

import "root:/core"
import "root:/services"

Item {
    id: root
    required property ShellScreen screen

    // Position at top right, below the top bar
    x: parent.width - implicitWidth - Sizing.margins.medium
    y: Sizing.topBarHeight + Sizing.margins.medium + Sizing.margins.small

    // Only take up space when there are visible (non-expired) notifications
    readonly property bool hasNotifications: {
        for (let i = 0; i < notificationColumn.children.length; i++) {
            const child = notificationColumn.children[i];
            if (child.implicitHeight > 0) return true;
        }
        return false;
    }
    implicitWidth: hasNotifications ? 380 : 0
    implicitHeight: notificationColumn.implicitHeight

    // Clip to hide sliding notifications
    clip: true

    ColumnLayout {
        id: notificationColumn
        width: 380
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
