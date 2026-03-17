import QtQuick
import Quickshell

import "root:/core"

Item {
    id: root
    required property ShellScreen screen
    required property bool visibility
    property Item triggerItem: null

    signal requestClose()

    width: implicitWidth
    height: implicitHeight

    readonly property real targetWidth: 400
    // Constrain height to available space below top bar
    readonly property real maxHeight: screen.height - Sizing.topBarHeight - Sizing.margins.small * 2
    readonly property real targetHeight: Math.min(500, maxHeight)

    clip: true

    // Track hover state for both menu and trigger
    property bool menuHovered: false
    property bool triggerHovered: triggerItem ? triggerItem.containsMouse || false : false

    Timer {
        id: closeTimer
        interval: 50
        onTriggered: {
            if (!root.menuHovered && !root.triggerHovered) {
                root.requestClose();
            }
        }
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            root.menuHovered = hovered;
            if (!hovered && !root.triggerHovered) {
                closeTimer.restart();
            } else {
                closeTimer.stop();
            }
        }
    }

    // Watch trigger item hover changes
    Connections {
        target: root.triggerItem
        function onContainsMouseChanged() {
            root.triggerHovered = root.triggerItem.containsMouse;
            if (!root.triggerHovered && !root.menuHovered) {
                closeTimer.restart();
            } else {
                closeTimer.stop();
            }
        }
    }

    states: [
        State {
            name: "hidden"
            when: !root.visibility
            PropertyChanges {
                target: root
                implicitWidth: 0
                implicitHeight: 0
                opacity: 0
            }
        },
        State {
            name: "visible"
            when: root.visibility
            PropertyChanges {
                target: root
                implicitWidth: root.targetWidth
                implicitHeight: root.targetHeight
                opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"
            to: "visible"
            reversible: true
            NumberAnimation {
                target: root
                properties: "implicitWidth,implicitHeight,opacity"
                duration: Animations.durations.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.snappy
            }
        }
    ]

    Loader {
        width: root.targetWidth
        height: root.targetHeight
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        source: "Content.qml"
    }
}
