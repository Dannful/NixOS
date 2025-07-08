import QtQuick
import QtQuick.Layouts
import Quickshell

import "root:/core"
import "root:/services"

CustomRect {
    required property ShellScreen screen
    required property PersistentProperties visibilities

    color: Colors.surface

    implicitHeight: Sizing.barWidth * screen.height / screen.width

    property alias timeText: timeText

    Date {
        id: timeText
        visibilities: parent.visibilities
        anchors.centerIn: parent
    }
}
