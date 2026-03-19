import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import "root:/core"

Row {
    id: root
    spacing: Sizing.spacing.medium

    Repeater {
        model: SystemTray.items

        TrayIcon {
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
