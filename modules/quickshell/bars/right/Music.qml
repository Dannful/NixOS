import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "root:/core"
import "root:/bars/components"

CustomRect {
    id: root
    required property Item panel
    color: Colors.background

    anchors {
        horizontalCenter: panel.right
        verticalCenter: panel.verticalCenter
    }

    readonly property MprisPlayer currentPlayer: Mpris.players.values.find(player => player.positionSupported) ?? null

    opacity: currentPlayer ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.durations.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
        }
    }

    states: [
        State {
            name: "retracted"
            when: !hoverArea.containsMouse
            PropertyChanges {
                target: root
                implicitWidth: 90
                implicitHeight: 90
                radius: 180
            }
        },
        State {
            name: "expanded"
            when: hoverArea.containsMouse
            PropertyChanges {
                target: root
                implicitWidth: 810
                implicitHeight: 150
                radius: 20
            }
            PropertyChanges {
                target: musicIcon
                scale: 0
                rotation: 180
            }
            PropertyChanges {
                target: contentLoader.item ? contentLoader.item.trackArt : null
                scale: 1
                rotation: 360
            }
            PropertyChanges {
                target: contentLoader.item
                opacity: 1
                scale: 1
            }
        }
    ]

    transitions: Transition {
        id: closingTransition
        from: "retracted"
        to: "expanded"
        reversible: true

        NumberAnimation {
            target: contentLoader.item
            properties: "opacity, scale"
            duration: Animations.durations.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
        }

        NumberAnimation {
            target: root
            properties: "implicitWidth, implicitHeight, radius"
            duration: Animations.durations.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
        }
        NumberAnimation {
            target: musicIcon
            properties: "scale"
            duration: Animations.durations.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
        }
        RotationAnimation {
            target: musicIcon
            duration: Animations.durations.medium
            direction: RotationAnimation.Clockwise
        }
    }

    MaterialIcon {
        id: musicIcon
        name: "music_note"
        size: Fonts.sizing.xlarge
        color: Colors.primary
        y: parent.implicitHeight / 2 - implicitHeight / 2
        x: parent.implicitWidth / 4 - implicitWidth / 2
        visible: parent.implicitWidth < 330
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true

        Loader {
            id: contentLoader
            anchors.fill: parent

            active: root.state === 'expanded' || closingTransition.running

            sourceComponent: Component {
                ExpandedPlayerControls {
                    playerRoot: root
                    currentPlayer: root.currentPlayer
                }
            }
        }
    }
}
