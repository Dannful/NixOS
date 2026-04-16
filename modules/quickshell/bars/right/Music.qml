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
    border.color: Colors.darkSurface
    border.width: 1

    anchors {
        horizontalCenter: panel.right
        verticalCenter: panel.verticalCenter
    }

    readonly property list<MprisPlayer> players: Mpris.players.values.filter(player => player.positionSupported)
    readonly property list<MprisPlayer> playingPlayers: players.filter(player => player.isPlaying)
    readonly property MprisPlayer currentPlayer: playingPlayers.length > 0 ? playingPlayers[playingPlayers.length - 1] : (players[Math.min(0, players.length - 1)] ?? null)
    readonly property bool contentExpanded: state === "expanded"

    opacity: currentPlayer ? 1 : 0

    Behavior on opacity {
        NumberAnimation {
            duration: Animations.durations.slow
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.smoothOut
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
        }
    ]

    transitions: Transition {
        id: closingTransition
        from: "retracted"
        to: "expanded"
        reversible: true

        NumberAnimation {
            target: root
            properties: "implicitWidth, implicitHeight, radius"
            duration: Animations.durations.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.snappy
        }

        NumberAnimation {
            target: musicIcon
            properties: "scale"
            duration: Animations.durations.medium
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.snappy
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

            active: root.opacity > 0 && (hoverArea.hoverEnabled || root.radius < 180)

            sourceComponent: Component {
                ExpandedPlayerControls {
                    playerRoot: root
                    currentPlayer: root.currentPlayer
                }
            }
        }
    }
}
