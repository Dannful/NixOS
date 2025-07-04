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

    MouseArea {
        hoverEnabled: true

        x: icon.x
        y: icon.y
        implicitWidth: (icon.implicitWidth + Sizing.barWidth) / 2
        implicitHeight: icon.implicitHeight

        onEntered: {
            setVisibility(true);
        }

        onExited: {
            setVisibility(false);
        }
    }

    MaterialIcon {
        id: icon
        text: root.iconName
        font.pixelSize: parent.iconSize
        color: Colors.foreground
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
    }
}
