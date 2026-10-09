// MediaPlayer.qml — floating MPRIS media player popup.
// FIX (v2): updateTimer previously kept running after the window auto-closed.
// The Scope now stops it whenever the window hides (see onVisibleChanged).
import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Scope {
    id: root

    // Mirrors the popup's visibility so the fix below can react declaratively.
    readonly property bool visible: win.visible

    readonly property MprisPlayer player: {
        const players = Mpris.players.values;
        for (let i = 0; i < players.length; i++)
            if (players[i].isPlaying) return players[i];
        return players.length > 0 ? players[0] : null;
    }

    // 1s timer that refreshes the progress bar while the popup is open.
    property real position: 0
    Timer {
        id: updateTimer
        interval: 1000
        repeat: true
        running: false // started/stopped by root.onVisibleChanged below
        onTriggered: root.position = root.player ? root.player.position : 0
    }

    // Auto-close a few seconds after playback stops / popup goes idle.
    Timer {
        id: hideTimer
        interval: 8000
        onTriggered: win.visible = false
    }

    Connections {
        target: root.player
        function onPlaybackStateChanged() {
            if (root.player && root.player.isPlaying) {
                win.visible = true;
                hideTimer.restart();
            }
        }
    }

    PanelWindow {
        id: win
        visible: false
        anchors {
            top: true
            right: true
        }
        margins {
            top: 52
            right: 12
        }
        implicitWidth: 340
        implicitHeight: 96
        color: "transparent"
        exclusiveZone: 0

        Rectangle {
            anchors.fill: parent
            radius: 16
            color: Colors.barBackground

            Column {
                anchors {
                    fill: parent
                    margins: 14
                }
                spacing: 8

                Text {
                    text: root.player ? (root.player.trackTitle || "Unknown title") : "Nothing playing"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.bold: true
                    color: Colors.text
                    elide: Text.ElideRight
                    width: parent.width
                }

                Text {
                    text: root.player ? (root.player.trackArtist || "") : ""
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    color: Colors.textDim
                    elide: Text.ElideRight
                    width: parent.width
                }

                // Progress bar
                Rectangle {
                    width: parent.width
                    height: 5
                    radius: 2.5
                    color: Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.15)

                    Rectangle {
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        readonly property real len: root.player ? root.player.length : 1
                        width: len > 0 ? (root.position / len) * parent.width : 0
                        radius: 2.5
                        color: Colors.accent
                    }
                }
            }
        }
    }

    // FIX: stop updateTimer when the popup hides (including auto-close),
    // so it never burns CPU/battery in the background. The timer's `running`
    // is managed entirely here (not bound), so this never kills a binding.
    onVisibleChanged: {
        if (!visible) updateTimer.running = false;
        else { root.position = root.player ? root.player.position : 0; updateTimer.running = true; }
    }
}
