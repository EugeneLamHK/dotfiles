import QtQuick
import QtQuick.Controls as QQC
import Quickshell
import Quickshell.Io
import "root:/" as Root

Rectangle {
    id: root

    signal clicked()

    property string command: ""
    property int interval: 5
    property bool parseJson: false
    property string clickCommand: ""
    property string scrollUpCommand: ""
    property string scrollDownCommand: ""

    property string displayText: ""
    property string tooltipText: ""
    property string className: ""

    property color textColor: Root.Colors.foreground
    property color hoverColor: Root.Colors.brightnessHoverBg
    property bool bold: false
    property int fontSize: Root.Colors.fontSize
    property int leftPadding: 10
    property int rightPadding: 10

    property var stateColors: ({})
    property var textTransform: (text) => text

    color: "transparent"
    implicitHeight: 30
    implicitWidth: Math.max(label.implicitWidth + leftPadding + rightPadding, 40)
    radius: 0

    Text {
        id: label
        anchors {
            left: parent.left
            leftMargin: root.leftPadding
            verticalCenter: parent.verticalCenter
        }
        text: root.displayText.length > 0 ? root.displayText : "VPN…"
        color: root.displayText.length > 0 ? (root.stateColors[root.className] || root.textColor) : "#aaaaaa"
        font.family: Root.Colors.fontFamily
        font.pixelSize: root.fontSize
        font.bold: root.bold
    }

    QQC.ToolTip {
        visible: mouseArea.containsMouse && root.tooltipText.length > 0
        text: root.tooltipText
        delay: 500
        timeout: 5000
        font.family: Root.Colors.fontFamily
        font.pixelSize: Root.Colors.fontSizeSmall
    }

    function stripPango(text) {
        return text.replace(/<<[^>]+>/g, "")
    }
    function extractPangoColor(text) {
        let m = text.match(/<<span[^>]*color=['"]([^'"]+)['"][^>]*>/i)
        return m ? m[1] : null
    }

    Process {
        id: proc
        command: ["/bin/bash", "-c", root.command]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim()
                let pangoCol = root.extractPangoColor(out)
                let cleanText = root.stripPango(out)

                if (cleanText.startsWith("{") && cleanText.endsWith("}")) {
                    try {
                        let obj = JSON.parse(cleanText)
                        root.displayText = root.textTransform(obj.text || "")
                        root.tooltipText = obj.tooltip || ""
                        root.className = obj.class || ""
                        if (pangoCol) root.textColor = pangoCol
                        return
                    } catch (e) {}
                }
                if (root.parseJson) {
                    try {
                        let obj = JSON.parse(cleanText)
                        root.displayText = root.textTransform(obj.text || "")
                        root.tooltipText = obj.tooltip || ""
                        root.className = obj.class || ""
                    } catch (e) {
                        root.displayText = root.textTransform(cleanText)
                        root.tooltipText = ""
                        root.className = ""
                    }
                } else {
                    root.displayText = root.textTransform(cleanText)
                }
                if (pangoCol) root.textColor = pangoCol
            }
        }
    }

    Timer {
        interval: root.interval * 1000
        running: root.command.length > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!proc.running) proc.running = true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.color = root.hoverColor
        onExited: root.color = "transparent"
        onClicked: {
            root.clicked()
            if (root.clickCommand.length > 0)
                clickProc.running = true
        }
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0 && root.scrollUpCommand.length > 0) {
                scrollUpProc.running = true
            } else if (wheel.angleDelta.y < 0 && root.scrollDownCommand.length > 0) {
                scrollDownProc.running = true
            }
        }
    }

    Process { id: clickProc; command: ["/bin/bash", "-c", root.clickCommand] }
    Process { id: scrollUpProc; command: ["/bin/bash", "-c", root.scrollUpCommand] }
    Process { id: scrollDownProc; command: ["/bin/bash", "-c", root.scrollDownCommand] }
}
