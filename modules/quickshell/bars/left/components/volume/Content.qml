import "root:/bars/components"
import Quickshell.Services.Pipewire

Meter {
    readonly property PwNode sink: Pipewire.defaultAudioSink
    iconName: {
        if (!sink || !sink.ready || sink.audio.volume === 0 || sink.audio.muted) {
            return "volume_off";
        } else if (sink.audio.volume < 0.33) {
            return "volume_mute";
        } else if (sink.audio.volume < 0.66) {
            return "volume_down";
        } else {
            return "volume_up";
        }
    }
    progress: !sink || !sink.ready || sink.audio.muted ? 0 : sink.audio.volume
    mutable: true
    onChanged: progress => {
        if (sink && sink.ready)
            sink.audio.volume = progress;
    }
    onIconClicked: {
        if (sink && sink.ready) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
}
