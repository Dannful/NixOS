import QtQuick
import Quickshell

import "root:/core"

Item {
    id: root
    required property ShellScreen screen
    required property bool visibility

    visible: width > 0 && height > 0

    states: [
        State {
            name: "hidden"
            when: !root.visibility
            PropertyChanges {
                target: root
                opacity: 0
                scale: 0
                implicitWidth: 0
                implicitHeight: 0
            }
        },
        State {
            name: "visible"
            when: root.visibility
            PropertyChanges {
                target: root
                opacity: 1
                scale: 1
                implicitWidth: 60
                implicitHeight: Fonts.sizing.large * 3 + Sizing.spacing.small * 4
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
                properties: "implicitWidth,implicitHeight,opacity,scale"
                duration: Animations.durations.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
            }
        }
    ]

    Content {
        id: content
    }
}
