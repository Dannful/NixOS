import QtQuick
import Quickshell

import "root:/core"

Item {
    id: root
    required property var setVisibility
    required property bool visibility
    required property string iconName
    property string iconSize: Fonts.sizing.large

    // Expose hover state for menu closing logic
    property alias containsMouse: mouseArea.containsMouse

    implicitWidth: Sizing.leftBarWidth
    implicitHeight: iconMetrics.height

    Rectangle {
        id: hoverBg
        anchors.centerIn: parent
        width: 0
        height: 0
        radius: Sizing.radius.medium
        color: Colors.darkSurface
        opacity: 0

        Behavior on width { NumberAnimation { duration: Animations.durations.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Animations.bezierCurves.snappy } }
        Behavior on height { NumberAnimation { duration: Animations.durations.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Animations.bezierCurves.snappy } }
        Behavior on opacity { NumberAnimation { duration: Animations.durations.fast } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            setVisibility(true);
            hoverBg.width = root.implicitWidth - 10;
            hoverBg.height = root.implicitHeight + 10;
            hoverBg.opacity = 1;
        }

        onExited: {
            // Don't close menu here - let the Wrapper handle it
            hoverBg.width = 0;
            hoverBg.height = 0;
            hoverBg.opacity = 0;
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
        color: mouseArea.containsMouse || root.visibility ? Colors.primary : Colors.foreground
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        scale: mouseArea.containsMouse ? 1.1 : 1.0
        Behavior on scale { NumberAnimation { duration: Animations.durations.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Animations.bezierCurves.snappy } }
    }
}
