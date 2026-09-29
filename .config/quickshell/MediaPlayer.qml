import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Window
import Quickshell
import Quickshell.Io
import "root:/" as Root

Scope {
    id: mpdRoot

    property bool visible: false
    property var track: ({ title: "", artist: "", album: "", art: "", status: "stopped", elapsed: 0, duration: 1, pct: 0 })

    function toggle() {
        visible = !visible
        if (visible) {
            updateTimer.running = true
            updateTrack()
        }
    }

    IpcHandler {
        target: "mediaplayer"
        function toggle(): void { mpdRoot.toggle() }
    }

    function updateTrack() {
        infoProc.running = true
    }

    function mpc(cmd) {
        controlProc.command = ["/bin/bash", "-c", "mpc " + cmd]
        controlProc.running = true
    }

    Process {
        id: infoProc
        command: ["python3", "/home/eugene/.config/quickshell/scripts/mpd_info.py"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    mpdRoot.track = JSON.parse(this.text.trim())
                } catch(e) {}
            }
        }
    }

    Process {
        id: controlProc
        command: []
    }

    Timer {
        id: updateTimer
        interval: 1000
        running: false
        repeat: true
        onTriggered: updateTrack()
    }

    Window {
        id: win
        title: "Media Player"
        visible: mpdRoot.visible
        width: 420
        height: 220
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool | Qt.NoDropShadowWindowHint
        color: "transparent"

        onActiveChanged: {
            if (!active && mpdRoot.visible) {
                closeTimer.restart()
            } else {
                closeTimer.stop()
            }
        }

        Timer {
            id: closeTimer
            interval: 300
            onTriggered: mpdRoot.visible = false
        }

        Rectangle {
            anchors.fill: parent
            color: Root.Colors.barBackground
            border.color: Root.Colors.accent
            border.width: 1
            radius: 8

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 140
                    Layout.alignment: Qt.AlignVCenter
                    color: Root.Colors.surface
                    radius: 4

                    Image {
                        anchors.fill: parent
                        anchors.margins: 4
                        source: mpdRoot.track.art ? "file://" + mpdRoot.track.art : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready && mpdRoot.track.art
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "♪"
                        color: Root.Colors.foregroundInactive
                        font.pixelSize: 48
                        visible: !parent.children[0].visible
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8

                    Text {
                        text: mpdRoot.track.title
                        color: Root.Colors.foreground
                        font.family: Root.Colors.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: mpdRoot.track.artist + (mpdRoot.track.album ? " — " + mpdRoot.track.album : "")
                        color: Root.Colors.foregroundInactive
                        font.family: Root.Colors.fontFamily
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 4
                        color: Root.Colors.surface
                        radius: 2

                        Rectangle {
                            width: parent.width * mpdRoot.track.pct
                            height: parent.height
                            color: Root.Colors.accent
                            radius: 2
                        }
                    }

                    Text {
                        text: {
                            let e = mpdRoot.track.elapsed
                            let d = mpdRoot.track.duration
                            let fmt = (s) => Math.floor(s/60) + ":" + String(s%60).padStart(2,'0')
                            return fmt(e) + " / " + fmt(d)
                        }
                        color: Root.Colors.textDim
                        font.family: Root.Colors.fontFamily
                        font.pixelSize: 9
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 20

                        Text {
                            text: "⏮"
                            color: Root.Colors.foreground
                            font.pixelSize: 18
                            MouseArea {
                                anchors.fill: parent
                                onClicked: mpdRoot.mpc("prev")
                            }
                        }

                        Text {
                            text: mpdRoot.track.status === "playing" ? "⏸" : "▶"
                            color: Root.Colors.accent
                            font.pixelSize: 22
                            MouseArea {
                                anchors.fill: parent
                                onClicked: mpdRoot.mpc("toggle")
                            }
                        }

                        Text {
                            text: "⏭"
                            color: Root.Colors.foreground
                            font.pixelSize: 18
                            MouseArea {
                                anchors.fill: parent
                                onClicked: mpdRoot.mpc("next")
                            }
                        }
                    }
                }
            }
        }
    }
}
