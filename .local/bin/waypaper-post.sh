#!/bin/bash
WALLPAPER="$1"

# Run matugen non-interactively
matugen image "$WALLPAPER" --source-color-index 0
echo "Matugen exit: $?"

# Update rofi wallpaper symlink
rm -f ~/.config/rofi/current-wallpaper
ln -s "$(realpath "$WALLPAPER")" ~/.config/rofi/current-wallpaper

# Generate Colors.qml for quickshell bar
python3 << 'PYEOF'
import json
with open('/home/eugene/.config/hypr/scripts/quickshell/qs_colors.json') as f:
    c = json.load(f)

qml = f'''pragma Singleton
import Quickshell
import QtQuick

Singleton {{
    id: root

    readonly property color foreground: "{c.get('text', '#eeeeee')}"
    readonly property color foregroundInactive: "{c.get('subtext0', '#aaaaaa')}"
    readonly property color textDim: "{c.get('subtext0', '#aaaaaa')}"
    readonly property color accent: "{c.get('blue', '#8bd0f0')}"
    readonly property color background: "{c.get('base', '#141318')}"
    readonly property color surface: "{c.get('mantle', '#1a1a1a')}"
    readonly property color barBackground: Qt.rgba(16/255, 16/255, 16/255, 0.5)

    readonly property color arch: "{c.get('blue', '#ffffff')}"
    readonly property color archHoverBg: "{c.get('surface0', '#2a2a2a')}"
    readonly property color vpn: "{c.get('teal', '#56b6c2')}"
    readonly property color vpnHoverBg: "{c.get('surface0', '#2a2a2a')}"
    readonly property color workspaceActive: "{c.get('text', '#ffffff')}"
    readonly property color workspaceInactive: "{c.get('subtext0', '#888888')}"
    readonly property color workspaceHover: "{c.get('blue', '#8bd0f0')}"

    readonly property color battery: "{c.get('green', '#a6e3a1')}"
    readonly property color batteryHoverBg: "{c.get('surface0', '#2a2a2a')}"
    readonly property color volume: "{c.get('text', '#ffffff')}"
    readonly property color volumeHoverBg: "{c.get('surface0', '#2a2a2a')}"

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
}}
'''

with open('/home/eugene/.config/quickshell/Colors.qml', 'w') as f:
    f.write(qml)
PYEOF

# Reload kitty colors
killall -SIGUSR1 kitty 2>/dev/null

# Reload waybar
killall -SIGUSR2 waybar 2>/dev/null

# Reload hyprland borders
hyprctl reload 2>/dev/null

# Reload quickshell bar colors
killall -SIGUSR1 quickshell 2>/dev/null || true

# ============================================
sudo -n ~/.local/bin/sddm-sync.sh >/dev/null 2>&1 &
