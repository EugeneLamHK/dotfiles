pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property color foreground: "#e0e2e8"
    readonly property color foregroundInactive: "#c2c7cf"
    readonly property color textDim: "#c2c7cf"
    readonly property color accent: "#9bcbfa"
    readonly property color background: "#101418"
    readonly property color surface: "#101418"
    readonly property color barBackground: Qt.rgba(16/255, 16/255, 16/255, 0.5)

    readonly property color arch: "#9bcbfa"
    readonly property color archHoverBg: "#1c2024"
    readonly property color vpn: "#b9c8da"
    readonly property color vpnHoverBg: "#1c2024"
    readonly property color workspaceActive: "#e0e2e8"
    readonly property color workspaceInactive: "#c2c7cf"
    readonly property color workspaceHover: "#9bcbfa"

    readonly property color battery: "#d3bfe6"
    readonly property color batteryHoverBg: "#1c2024"
    readonly property color volume: "#e0e2e8"
    readonly property color volumeHoverBg: "#1c2024"

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
