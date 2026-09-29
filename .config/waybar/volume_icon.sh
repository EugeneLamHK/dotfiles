#!/bin/bash
# ── volume_icon.sh ─────────────────────────────────────────────────────────
# Description: Shows volume icon that changes based on volume level (white)
# Usage: Waybar `custom/volume` every 2s
# Dependencies: pactl or amixer
# ───────────────────────────────────────────────────────────────────────────

# Try to get volume using pactl (PulseAudio)
if command -v pactl &> /dev/null; then
    volume_info=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null)
    if [ $? -eq 0 ]; then
        volume=$(echo "$volume_info" | grep -oP '\d+%' | head -1 | tr -d '%')
        muted=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -o "yes")
    fi
fi

# Fallback to amixer if pactl failed
if [ -z "$volume" ] && command -v amixer &> /dev/null; then
    volume_info=$(amixer get Master 2>/dev/null)
    if [ $? -eq 0 ]; then
        volume=$(echo "$volume_info" | grep -oP '\d+%' | head -1 | tr -d '%')
        muted=$(echo "$volume_info" | grep -o "\[off\]")
    fi
fi

# Default values if everything failed
if [ -z "$volume" ]; then
    volume=0
fi

# Choose icon based on mute status and volume level
if [ -n "$muted" ]; then
    icon="󰝟"  # muted
elif [ "$volume" -eq 0 ]; then
    icon="󰝟"  # zero volume
elif [ "$volume" -le 30 ]; then
    icon="󰕿"  # low volume
elif [ "$volume" -le 70 ]; then
    icon="󰖀"  # medium volume
else
    icon="󰕾"  # high volume
fi

# Output just the icon (white color will be set in CSS)
echo "$icon"
