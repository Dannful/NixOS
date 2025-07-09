import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "root:/core"

CustomRect {
    id: root
    required property Item panel
    color: Colors.background

    anchors {
        horizontalCenter: panel.right
        verticalCenter: panel.verticalCenter
    }

    readonly property list<MprisPlayer> validPlayers: Mpris.players.values.filter(player => player.lengthSupported && player.positionSupported)
    readonly property MprisPlayer currentPlayer: validPlayers.length > 0 ? validPlayers[0] : null

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
            PropertyChanges {
                target: row
                opacity: 0
                scale: 0
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
                target: trackArt
                scale: 1
                rotation: 360
            }
            PropertyChanges {
                target: row
                opacity: 1
                scale: 1
            }
        }
    ]

    transitions: Transition {
        from: "retracted"
        to: "expanded"
        reversible: true
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
        NumberAnimation {
            target: row
            properties: "opacity, scale"
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

        RowLayout {
            id: row
            visible: root.currentPlayer !== null
            spacing: Sizing.spacing.small

            anchors.fill: parent
            anchors.margins: Sizing.margins.medium

            ClippingRectangle {
                Layout.fillHeight: true
                implicitWidth: 120
                radius: Sizing.radius.medium

                CustomImage {
                    id: trackArt
                    source: root.currentPlayer?.trackArtUrl
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    scale: 0
                }
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignTop

                CustomText {
                    text: root.currentPlayer?.trackTitle
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    size: Fonts.sizing.small
                }

                CustomText {
                    text: root.currentPlayer?.trackArtist
                    Layout.alignment: Qt.AlignCenter
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    size: Fonts.sizing.small
                }

                Slider {
                    Layout.fillWidth: true
                    value: root.currentPlayer !== null ? root.currentPlayer.position / root.currentPlayer.length : 0
                    onMoved: {
                        if (root.currentPlayer !== null)
                            root.currentPlayer.position = value * root.currentPlayer.length;
                    }
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0

                    FrameAnimation {
                        running: root.currentPlayer.playbackState == MprisPlaybackState.Playing
                        onTriggered: root.currentPlayer.positionChanged()
                    }
                }

                RowLayout {
                    ControlIcon {
                        Layout.fillWidth: true
                        name: "skip_previous"
                        onClicked: root.currentPlayer?.previous()
                        disabled: !root.currentPlayer?.canGoPrevious
                    }

                    ControlIcon {
                        Layout.fillWidth: true
                        name: root.currentPlayer?.isPlaying ? "pause" : "play_arrow"
                        onClicked: root.currentPlayer?.isPlaying ? root.currentPlayer?.pause() : root.currentPlayer?.play()
                    }

                    ControlIcon {
                        name: "skip_next"
                        onClicked: root.currentPlayer?.next()
                        disabled: !root.currentPlayer?.canGoNext
                    }
                }
            }

            Item {
                Layout.preferredWidth: root.implicitWidth / 2 - Sizing.margins.medium
            }
        }
    }

    component ControlIcon: MaterialIcon {
        id: root
        signal clicked
        property bool disabled: false
        color: disabled ? Colors.darkSurface : (controlArea.containsMouse ? Colors.secondary : Colors.primary)
        size: Fonts.sizing.large

        MouseArea {
            id: controlArea
            hoverEnabled: !parent.disabled
            anchors.fill: parent
            onClicked: {
                if (!root.disabled)
                    parent.clicked();
            }
        }
    }
}
