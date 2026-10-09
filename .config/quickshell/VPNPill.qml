// VPNPill.qml — ProtonVPN status pill.
// Connected state = the proton0 interface exists (checked via `ip link show
// proton0`). Refreshes every 30s and immediately on click. No toggling.
import Quickshell
import Quickshell.Io
import QtQuick

Rectangle {
    id: root
    implicitWidth: row.implicitWidth + 24
    implicitHeight: 22
    radius: 17
    color: Colors.pillBackground

    property bool connected: false
    readonly property bool hovered: hoverArea.containsMouse

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 7

        Text {
            text: root.connected ? "VPN" : "VPN off"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            color: root.connected ? Colors.text : Colors.textDim
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // 30s poll — battery-conscious; also refreshed on click.
    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: checkProc.running = true
    }

    Process {
        id: checkProc
        command: ["sh", "-c", "ip link show proton0 >/dev/null 2>&1 && echo up || echo down"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim();
                if (line === "up") root.connected = true;
                else if (line === "down") root.connected = false;
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: checkProc.running = true // refresh only — no toggle
    }
}
