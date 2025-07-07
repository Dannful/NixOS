import QtQuick
import QtQuick.Layouts
import Quickshell

import "root:/core"
import "root:/services"

CustomRect {
    required property ShellScreen screen

    color: Colors.surface

    implicitHeight: Sizing.barWidth * screen.height / screen.width
    implicitWidth: screen.width * 0.75
    radius: Sizing.radius.large

    Text {
        anchors.centerIn: parent
        font.family: "FiraCode Nerd Font Mono"
        text: System.time
    }
}
