// osd/OSD.qml — on-screen display for volume changes (PipeWire, event-driven).
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import "root:/" as Root

Scope {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property real lastVolume: -1

    Connections {
        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
        function onVolumeChanged() {
            const v = Pipewire.defaultAudioSink.audio.volume;
            if (root.lastVolume >= 0 && Math.abs(v - root.lastVolume) > 0.001) {
                root.lastVolume = v;
                win.visible = true;
                hideTimer.restart();
            } else {
                root.lastVolume = v;
            }
        }
        function onMutedChanged() {
            win.visible = true;
            hideTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: win.visible = false
    }

    PanelWindow {
        id: win
        visible: false
        anchors {
            bottom: true
        }
        margins {
            bottom: 60
        }
        implicitWidth: 240
        implicitHeight: 56
        color: "transparent"
        exclusiveZone: 0
        mask: Region {}

        Rectangle {
            anchors.fill: parent
            radius: 20
            color: Root.Colors.barBackground

            Row {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    readonly property var audio: Pipewire.defaultAudioSink
                        ? Pipewire.defaultAudioSink.audio : null
                    text: (audio && audio.muted) ? "\uf6a9" : "\uf028"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    color: (audio && audio.muted) ? Root.Colors.danger : Root.Colors.accent
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 150
                    height: 8
                    radius: 4
                    color: Qt.rgba(Root.Colors.text.r, Root.Colors.text.g, Root.Colors.text.b, 0.15)
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        readonly property real vol: {
                            const s = Pipewire.defaultAudioSink;
                            return (s && s.audio) ? Math.min(s.audio.volume, 1.0) : 0;
                        }
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        width: vol * parent.width
                        radius: 4
                        color: Root.Colors.accent
                    }
                }
            }
        }
    }
}
