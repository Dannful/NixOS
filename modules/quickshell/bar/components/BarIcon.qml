import QtQuick
import Quickshell

import "root:/core"

Item {
    id: root
    required property var setVisibility
    required property bool visibility
    required property string iconName
    property string iconSize: Fonts.sizing.large

    MouseArea {
        hoverEnabled: true

        anchors.fill: parent

        onEntered: {
            setVisibility(true);
        }

        onExited: {
            setVisibility(hoverArea.containsMouse);
        }
    }

    MouseArea {
        id: hoverArea
        hoverEnabled: true

        x: icon.x + icon.implicitWidth
        y: icon.y
        implicitWidth: root.parent.implicitWidth
        implicitHeight: icon.implicitHeight

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
