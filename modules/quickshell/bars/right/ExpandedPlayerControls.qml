import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "root:/core"
import "root:/bars/components"

RowLayout {
    id: expandedControlsRoot

    required property Item playerRoot
    required property MprisPlayer currentPlayer
    property alias trackArt: trackArt

    opacity: 0
    scale: 0
    visible: currentPlayer !== null
    spacing: Sizing.spacing.small
    anchors.fill: parent
    anchors.margins: Sizing.margins.medium

    Meter {
        implicitWidth: Sizing.meter.width * 0.75
        visible: currentPlayer !== null && currentPlayer.volumeSupported
        Layout.fillHeight: true
        iconName: {
            const volume = currentPlayer?.volume ?? 0;
            if (volume === 0)
                return "volume_off";
            if (volume < 0.33)
                return "volume_mute";
            if (volume < 0.66)
                return "volume_down";
            return "volume_up";
        }
        iconSize: Fonts.sizing.medium
        progress: currentPlayer?.volume
        mutable: currentPlayer?.canControl
        onChanged: value => {
            if (currentPlayer !== null)
                currentPlayer.volume = value;
        }
    }

    ClippingRectangle {
        Layout.fillHeight: true
        implicitWidth: 120
        radius: Sizing.radius.medium
        visible: currentPlayer?.trackArtUrl !== undefined && currentPlayer.trackArtUrl !== null && currentPlayer.trackArtUrl.trim().length > 0

        CustomImage {
            id: trackArt
            source: currentPlayer?.trackArtUrl
            anchors.fill: parent
            sourceSize.width: parent.implicitWidth
            sourceSize.height: parent.implicitHeight
            fillMode: Image.PreserveAspectCrop
            scale: 0
            asynchronous: true
        }
    }

    ColumnLayout {
        Layout.fillHeight: true
        Layout.alignment: Qt.AlignTop

        CustomText {
            text: currentPlayer?.trackTitle
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            size: Fonts.sizing.small
        }

        CustomText {
            text: currentPlayer?.trackArtist
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            size: Fonts.sizing.small
        }

        Slider {
            Layout.fillWidth: true
            value: currentPlayer !== null ? currentPlayer.position / currentPlayer.length : 0
            onMoved: {
                if (currentPlayer !== null)
                    currentPlayer.position = value * currentPlayer.length;
            }
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0

            FrameAnimation {
                running: currentPlayer.playbackState == MprisPlaybackState.Playing
                onTriggered: currentPlayer.positionChanged()
            }
        }

        Item {
            Layout.fillWidth: true
            ControlIcon {
                anchors.left: parent.left
                name: "skip_previous"
                onClicked: currentPlayer?.previous()
                disabled: !currentPlayer?.canGoPrevious
            }

            ControlIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                name: currentPlayer?.isPlaying ? "pause" : "play_arrow"
                onClicked: currentPlayer?.isPlaying ? currentPlayer?.pause() : currentPlayer?.play()
            }

            ControlIcon {
                name: "skip_next"
                onClicked: currentPlayer?.next()
                disabled: !currentPlayer?.canGoNext
                anchors.right: parent.right
            }
        }
    }

    Item {
        Layout.preferredWidth: playerRoot.implicitWidth / 2 - Sizing.margins.medium
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
