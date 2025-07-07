import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import "root:/core"

Column {
    id: root
    spacing: Sizing.spacing.medium

    Repeater {
        model: SystemTray.items

        TrayIcon {
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
