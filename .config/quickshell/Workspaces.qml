// Workspaces.qml — Hyprland workspaces row with hiragana labels.
// Event-driven via Quickshell.Hyprland (no polling).
import Quickshell
import Quickshell.Hyprland
import QtQuick

Row {
    id: root
    spacing: 4

    // Hiragana labels (user's rice: ひ ら や す み)
    readonly property var labels: ["ひ", "ら", "や", "す", "み"]

    Repeater {
        model: labels.length

        Rectangle {
            id: ws
            required property int index
            readonly property int wsId: index + 1
            readonly property HyprlandWorkspace workspace: {
                const list = Hyprland.workspaces.values;
                for (let i = 0; i < list.length; i++)
                    if (list[i].id === wsId) return list[i];
                return null;
            }
            readonly property bool active: Hyprland.focusedWorkspace !== null
                && Hyprland.focusedWorkspace.id === wsId
            readonly property bool occupied: workspace !== null
            readonly property bool hovered: area.containsMouse

            width: 20
            height: 20
            radius: 10
            color: hovered
                ? Qt.rgba(Colors.text.r, Colors.text.g, Colors.text.b, 0.12)
                : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: root.labels[ws.index]
                font.family: "Noto Sans CJK JP"
                font.pixelSize: 13
                font.bold: ws.active
                color: ws.active
                    ? "#ffffff"
                    : (ws.occupied ? Colors.workspaceOccupied : Colors.workspaceEmpty)
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: area
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + ws.wsId)
            }
        }
    }
}
