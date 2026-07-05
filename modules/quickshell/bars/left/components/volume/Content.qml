import QtQuick
import QtQuick.Controls
import Quickshell.Services.Pipewire
import "root:/bars/components"
import "root:/core"

Item {
    id: root
    readonly property PwNode sink: Pipewire.defaultAudioSink
    implicitWidth: Sizing.leftBarWidth
    implicitHeight: Sizing.meter.height

    HoverHandler {
        id: hoverHandler
    }

    ToolTip {
        parent: root
        visible: hoverHandler.hovered
        delay: 400
        x: hoverHandler.point.position.x + 12
        y: hoverHandler.point.position.y - implicitHeight / 2
        text: {
            if (!root.sink || !root.sink.ready) return "No audio sink";
            const name = root.sink.nickname || root.sink.description || root.sink.name || "Output";
            const pct = Math.round(root.sink.audio.volume * 100);
            return root.sink.audio.muted ? `${name}\nMuted` : `${name}\n${pct}%`;
        }
    }

    Meter {
        id: meter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        iconName: {
            if (!root.sink || !root.sink.ready || root.sink.audio.volume === 0 || root.sink.audio.muted) {
                return "volume_off";
            } else if (root.sink.audio.volume < 0.33) {
                return "volume_mute";
            } else if (root.sink.audio.volume < 0.66) {
                return "volume_down";
            } else {
                return "volume_up";
            }
        }
        progress: !root.sink || !root.sink.ready || root.sink.audio.muted ? 0 : root.sink.audio.volume
        mutable: true
        onChanged: progress => {
            if (root.sink && root.sink.ready)
                root.sink.audio.volume = progress;
        }
        onIconClicked: {
            if (root.sink && root.sink.ready) {
                root.sink.audio.muted = !root.sink.audio.muted;
            }
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
}
