// VPNIcon.qml — ProtonVPN status glyph (Nerd Font).
// Checks the proton0 wireguard interface every 10s — one ~2ms `ip link`
// spawn per tick, effectively zero battery cost.
import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root
    implicitWidth: 18
    implicitHeight: 22

    property bool connected: false

    Process {
        id: vpnProc
        command: ["sh", "-c", "ip link show proton0 >/dev/null 2>&1 && echo on || echo off"]
        stdout: SplitParser {
            onRead: data => root.connected = (data.trim() === "on")
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: vpnProc.running = true
    }

    Text {
        anchors.centerIn: parent
        // nf-fa-shield (JetBrainsMono Nerd Font) when connected, ✕ when not
        text: root.connected ? "\uf132" : "✕"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 13
        color: root.connected ? "#ffffff" : "#888888"
        Behavior on color { ColorAnimation { duration: 200 } }
    }
}
