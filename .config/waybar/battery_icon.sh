#!/bin/bash
# ── battery_icon.sh ────────────────────────────────────────────────────────
# Description: Shows battery icon with percentage (no ASCII bar)
# Usage: Waybar `custom/battery` every 10s
# Dependencies: /sys/class/power_supply/BAT*
# ───────────────────────────────────────────────────────────────────────────

# Find battery
battery_path=""
for bat in /sys/class/power_supply/BAT*; do
    if [ -d "$bat" ]; then
        battery_path="$bat"
        break
    fi
done

if [ -z "$battery_path" ]; then
    echo "󰂑 N/A"
    exit 1
fi

# Read battery info
capacity=$(cat "$battery_path/capacity" 2>/dev/null)
status=$(cat "$battery_path/status" 2>/dev/null)

if [ -z "$capacity" ]; then
    echo "󰂑 N/A"
    exit 1
fi

# Choose icon based on status and capacity
if [ "$status" = "Charging" ]; then
    icon="󰂄"
elif [ "$capacity" -ge 90 ]; then
    icon="󰁹"
elif [ "$capacity" -ge 80 ]; then
    icon="󰂂"
elif [ "$capacity" -ge 70 ]; then
    icon="󰂁"
elif [ "$capacity" -ge 60 ]; then
    icon="󰂀"
elif [ "$capacity" -ge 50 ]; then
    icon="󰁿"
elif [ "$capacity" -ge 40 ]; then
    icon="󰁾"
elif [ "$capacity" -ge 30 ]; then
    icon="󰁽"
elif [ "$capacity" -ge 20 ]; then
    icon="󰁼"
elif [ "$capacity" -ge 10 ]; then
    icon="󰁻"
else
    icon="󰁺"
fi

# Output format: icon percentage%
echo "$icon $capacity%"
