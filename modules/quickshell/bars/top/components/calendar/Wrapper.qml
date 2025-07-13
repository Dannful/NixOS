import QtQuick
import Quickshell

import "root:/core"

Item {
    id: root
    required property ShellScreen screen
    required property bool visibility

    visible: height > 0
    implicitWidth: 250

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
                implicitHeight: 180
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
                easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
            }
        }
    ]

    Loader {
        anchors.fill: parent
        source: "Content.qml"
        active: root.implicitHeight > 0
    }
}
