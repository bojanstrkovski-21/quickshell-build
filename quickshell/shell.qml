//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import "./modules/bar/"

ShellRoot {
    id: root

    // Volume properties for Pipewire integration
    property var defaultAudioSink: Pipewire.defaultAudioSink
    property int volume: defaultAudioSink && defaultAudioSink.audio
        ? Math.round(defaultAudioSink.audio.volume * 100)
        : 0
    property bool volumeMuted: defaultAudioSink && defaultAudioSink.audio
        ? defaultAudioSink.audio.muted
        : false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Loader {
        active: true
        sourceComponent: Bar {
            volume: root.volume
            volumeMuted: root.volumeMuted
            defaultAudioSink: root.defaultAudioSink
        }
    }
}
