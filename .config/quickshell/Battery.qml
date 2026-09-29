import QtQuick
import Quickshell.Io
import "root:/" as Root

Rectangle {
    id: root

    property string displayText: ""
    property string tooltipText: "Battery Status"

    color: Root.Colors.battery
    implicitHeight: 22
    implicitWidth: batteryText.implicitWidth + 16
    radius: 11

    Text {
        id: batteryText
        anchors.centerIn: parent
        text: root.displayText
        color: "#ffffff"
        font.family: Root.Colors.fontFamily
        font.pixelSize: 11
        font.bold: true
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.color = Qt.darker(Root.Colors.battery, 1.2)
        onExited: root.color = Root.Colors.battery
    }

    Process {
        id: proc
        command: ["/bin/bash", "-c", "~/.config/waybar/scripts/battery_icon.sh"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let raw = text.trim()
                let num = raw.replace(/[^\d]/g, '')
                root.displayText = num
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }
}
