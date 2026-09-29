import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Window
import Quickshell
import Quickshell.Io
import "root:/" as Root

Scope {
    id: launcherRoot

    property bool launcherVisible: false
    property bool canAutoClose: false
    property string wallpaperBuster: ""

    function toggle() {
        launcherVisible = !launcherVisible
        if (launcherVisible) {
            loadApps.running = false
            loadApps.running = true
            canAutoClose = false
            wallpaperBuster = "?" + Date.now()
            searchQuery = ""
            searchInput.text = ""
            filterApps()
            openGraceTimer.start()
            Qt.callLater(() => searchInput.forceActiveFocus())
        }
    }

    Timer {
        id: openGraceTimer
        interval: 300
        onTriggered: launcherRoot.canAutoClose = true
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { launcherRoot.toggle() }
    }

    property var allApps: []
    property var filteredApps: []
    property string searchQuery: ""

    function filterApps() {
        let q = searchQuery.toLowerCase()
        if (!q) {
            filteredApps = allApps
        } else {
            filteredApps = allApps.filter(a => a.name.toLowerCase().includes(q))
        }
    }

    function runApp(exec) {
        runProc.command = ["/bin/bash", "-c", exec + " &"]
        runProc.running = true
        launcherVisible = false
    }

    // Load apps ONCE at startup (not on every toggle)
    Process {
        id: loadApps
        command: ["/bin/bash", "-c", "~/.config/quickshell/scripts/launcher.sh"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let out = this.text.trim()
                let lines = out ? out.split("\n") : []
                let parsed = []
                for (let line of lines) {
                    if (!line.trim()) continue
                    try {
                        let obj = JSON.parse(line)
                        if (obj.name && obj.exec) parsed.push(obj)
                    } catch(e) {}
                }
                launcherRoot.allApps = parsed
                launcherRoot.filterApps()
            }
        }
    }

    Process {
        id: runProc
        command: []
    }

    Window {
        id: launcherWindow
        title: "Quickshell Launcher"
        visible: launcherRoot.launcherVisible
        width: 750
        height: 625
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool | Qt.NoDropShadowWindowHint
        color: "transparent"

        onActiveChanged: {
            if (launcherRoot.canAutoClose && !active && launcherRoot.launcherVisible) {
                closeTimer.restart()
            } else {
                closeTimer.stop()
            }
        }

        Timer {
            id: closeTimer
            interval: 500
            onTriggered: {
                if (!launcherWindow.active && launcherRoot.launcherVisible)
                    launcherRoot.launcherVisible = false
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: "#8bd0f0"
            border.width: 2
            radius: 3

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    Layout.preferredWidth: 300
                    Layout.fillHeight: true
                    color: "transparent"
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: "file:///home/eugene/.config/rofi/current-wallpaper" + launcherRoot.wallpaperBuster
                        fillMode: Image.PreserveAspectCrop
                        cache: false
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45
                            color: "#0f1417"

                            QQC.TextField {
                                id: searchInput
                                anchors.fill: parent
                                anchors.margins: 8
                                color: "#eeeeee"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                placeholderText: "Type to search..."
                                placeholderTextColor: Qt.rgba(1,1,1,0.3)
                                background: Rectangle { color: "transparent" }

                                onTextChanged: {
                                    launcherRoot.searchQuery = text
                                    launcherRoot.filterApps()
                                }

                                Keys.onEscapePressed: launcherRoot.launcherVisible = false
                                Keys.onReturnPressed: {
                                    if (filteredApps.length > 0)
                                        launcherRoot.runApp(filteredApps[0].exec)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Qt.rgba(27/255, 32/255, 35/255, 0.8)

                            ListView {
                                anchors.fill: parent
                                anchors.margins: 5
                                clip: true
                                model: filteredApps

                                delegate: Rectangle {
                                    required property var modelData
                                    width: ListView.view.width
                                    height: 44
                                    color: mouseArea.containsMouse ? "#1b2023" : "transparent"
                                    radius: 3

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        anchors.topMargin: 6
                                        anchors.bottomMargin: 6
                                        spacing: 12

                                        Image {
                                            Layout.preferredWidth: 32
                                            Layout.preferredHeight: 32
                                            source: modelData.icon ? Quickshell.iconPath(modelData.icon, 32) : ""
                                            sourceSize: Qt.size(32, 32)
                                            smooth: true
                                            mipmap: true
                                            visible: status === Image.Ready && modelData.icon
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: mouseArea.containsMouse ? "#ffffff" : "#eeeeee"
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                        }
                                    }

                                    MouseArea {
                                        id: mouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: launcherRoot.runApp(modelData.exec)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
