import QtQuick
import Quickshell

import "root:/core"

Item {
    id: root
    required property ShellScreen screen
    required property bool visibility

    width: implicitWidth
    height: implicitHeight
    
    readonly property real targetWidth: Sizing.networkMenuWidth + Sizing.margins.medium * 2
    readonly property real targetHeight: 350
    
    clip: true

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
                duration: Animations.durations.medium
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
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
