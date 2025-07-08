import QtQuick
import Quickshell

import "root:/core"
import "root:/core"

Item {
    id: root
    required property var setVisibility
    required property bool visibility
    required property string iconName
    property string iconSize: Fonts.sizing.large

    implicitWidth: Sizing.leftBarWidth
    implicitHeight: iconMetrics.height

    MouseArea {
        hoverEnabled: true

        x: icon.x
        y: icon.y
        implicitWidth: (icon.implicitWidth + Sizing.leftBarWidth) / 2
        implicitHeight: icon.implicitHeight

        onEntered: {
            setVisibility(true);
        }

        onExited: {
            setVisibility(false);
        }
    }

    TextMetrics {
        id: iconMetrics
        font: icon.font
        text: icon.name
    }

    MaterialIcon {
        id: icon
        name: root.iconName
        size: parent.iconSize
        color: Colors.foreground
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
    }
}
