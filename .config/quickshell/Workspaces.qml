import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Io
import "root:/" as Root

RowLayout {
    spacing: 0

    Process {
        id: wsDispatcher
        property int targetWs: 0
        command: ["/bin/bash", "-c", "hyprctl dispatch workspace " + targetWs]
    }

    Repeater {
        model: 5

        Rectangle {
            id: wsRect
            property int wsId: index + 1
            property var wsObj: Hyprland.workspaces.values.find(w => w.id === wsId)
            property bool isActive: Hyprland.focusedWorkspace?.id === wsId
            property bool exists: wsObj !== undefined

            implicitWidth: wsText.implicitWidth + 16
            implicitHeight: 30
            color: "transparent"
            radius: 0

            Text {
                id: wsText
                anchors.centerIn: parent
                text: ["ひ", "ら", "や", "す", "み"][index]
                color: wsRect.isActive
                    ? Root.Colors.workspaceActive
                    : Root.Colors.workspaceInactive
                font.family: "Noto Sans CJK JP"
                font.pixelSize: Root.Colors.fontSizeWorkspace
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    if (!wsRect.isActive)
                        wsText.color = Root.Colors.workspaceHover
                }
                onExited: {
                    wsText.color = wsRect.isActive
                        ? Root.Colors.workspaceActive
                        : Root.Colors.workspaceInactive
                }
                onClicked: {
                    wsDispatcher.targetWs = wsRect.wsId
                    wsDispatcher.running = true
                }
            }
        }
    }
}
