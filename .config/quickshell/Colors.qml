pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property color foreground: "#e2e2e9"
    readonly property color foregroundInactive: "#c4c6cf"
    readonly property color textDim: "#c4c6cf"
    readonly property color accent: "#a9c7ff"
    readonly property color background: "#111318"
    readonly property color surface: "#111318"
    readonly property color barBackground: Qt.rgba(16/255, 16/255, 16/255, 0.5)

    readonly property color arch: "#a9c7ff"
    readonly property color archHoverBg: "#1d2024"
    readonly property color vpn: "#bdc7dc"
    readonly property color vpnHoverBg: "#1d2024"
    readonly property color workspaceActive: "#e2e2e9"
    readonly property color workspaceInactive: "#c4c6cf"
    readonly property color workspaceHover: "#a9c7ff"

    readonly property color battery: "#dcbce1"
    readonly property color batteryHoverBg: "#1d2024"
    readonly property color volume: "#e2e2e9"
    readonly property color volumeHoverBg: "#1d2024"

    readonly property color brightness100: "#f1c40f"
    readonly property color brightness75: "#e67e22"
    readonly property color brightness50: "#e91e63"
    readonly property color brightness25: "#e74c3c"
    readonly property color brightnessError: "#95a5a6"
    readonly property color brightnessHoverBg: Qt.rgba(1, 1, 1, 0.1)
    readonly property color dayOfWeek: "#bb9af7"
    readonly property color dayOfWeekHoverBg: Qt.rgba(187/255, 154/255, 247/255, 0.1)

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 15
    readonly property int fontSizeSmall: 13
    readonly property int fontSizeLarge: 17
    readonly property int fontSizeWorkspace: 18
}
