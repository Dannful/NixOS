import QtQuick
import QtQuick.Layouts
import Quickshell

import "root:/core"
import "root:/services"

CustomRect {
    required property ShellScreen screen
    required property PersistentProperties visibilities

    color: Colors.surface

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
}
