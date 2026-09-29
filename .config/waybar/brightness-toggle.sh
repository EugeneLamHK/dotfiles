#!/bin/bash
# ── brightness-toggle.sh ───────────────────────────────────────────────────
# Description: Toggle brightness between preset levels or open settings
# Usage: Called by Waybar brightness module on click
# Dependencies: brightnessctl
# ───────────────────────────────────────────────────────────────────────────

# Check if brightnessctl is available
if ! command -v brightnessctl &> /dev/null; then
    # Fallback: try to open display settings
    if command -v gnome-control-center &> /dev/null; then
        gnome-control-center display &
    elif command -v systemsettings5 &> /dev/null; then
        systemsettings5 kcm_displayconfiguration &
    elif command -v xfce4-display-settings &> /dev/null; then
        xfce4-display-settings &
    else
        notify-send "Brightness" "No brightness control available" -t 2000
    fi
    exit 0
fi

# Get current brightness percentage
brightness=$(brightnessctl get 2>/dev/null)
max_brightness=$(brightnessctl max 2>/dev/null)

if [ -z "$brightness" ] || [ -z "$max_brightness" ] || [ "$max_brightness" -eq 0 ]; then
    notify-send "Brightness" "Cannot read brightness level" -t 2000
    exit 1
fi

percent=$((brightness * 100 / max_brightness))

# Toggle between brightness levels: 25% -> 50% -> 75% -> 100% -> 25%
if [ "$percent" -lt 30 ]; then
    new_percent=50
elif [ "$percent" -lt 60 ]; then
    new_percent=75
elif [ "$percent" -lt 85 ]; then
    new_percent=100
else
    new_percent=25
fi

# Set new brightness
brightnessctl set "${new_percent}%" > /dev/null 2>&1

# Show notification
notify-send "Brightness" "Set to ${new_percent}%" -t 1500
