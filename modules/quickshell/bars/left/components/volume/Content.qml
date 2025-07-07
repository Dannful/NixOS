import "root:/bars/left/components"
import Quickshell.Services.Pipewire

Meter {
    readonly property PwNode sink: Pipewire.defaultAudioSink
    iconName: {
        if (sink.audio.volume === 0 || sink.audio.muted) {
            return "volume_mute";
        } else if (sink.audio.volume < 0.33) {
            return "volume_down";
        } else {
            return "volume_up";
        }
    }
    progress: sink.audio.muted ? 0 : sink.audio.volume
    mutable: true
    onChanged: progress => {
        if (sink.ready)
            sink.audio.volume = progress;
    }
    onIconClicked: {
        if (sink.ready) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
}
