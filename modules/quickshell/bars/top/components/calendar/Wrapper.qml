import QtQuick
import Quickshell

import "root:/core"

Item {
    id: root
    required property ShellScreen screen
    required property bool visibility
    property Item triggerItem: null

    signal requestClose()

    visible: height > 0
    implicitWidth: 350

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
                implicitHeight: 0
                opacity: 0
            }
        },
        State {
            name: "visible"
            when: root.visibility
            PropertyChanges {
                target: root
                implicitHeight: 400
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
                properties: "implicitHeight,opacity"
                duration: Animations.durations.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.snappy
            }
        }
    ]

    Loader {
        anchors.fill: parent
        source: "Content.qml"
        active: root.implicitHeight > 0
    }
}
