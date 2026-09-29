#!/bin/bash
# ── volume-toggle.sh ───────────────────────────────────────────────────────
# Description: Toggle volume mute or open volume control
# Usage: Called by Waybar volume module on click
# Dependencies: pactl or amixer
# ───────────────────────────────────────────────────────────────────────────

# Try to toggle mute using pactl
if command -v pactl &> /dev/null; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle 2>/dev/null
    if [ $? -eq 0 ]; then
        # Check if now muted or unmuted
        muted=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | grep -o "yes")
        if [ -n "$muted" ]; then
            notify-send "Volume" "Muted" -t 1500
        else
            notify-send "Volume" "Unmuted" -t 1500
        fi
        exit 0
    fi
fi

# Fallback to amixer
if command -v amixer &> /dev/null; then
    amixer set Master toggle > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        muted=$(amixer get Master | grep -o "\[off\]")
        if [ -n "$muted" ]; then
            notify-send "Volume" "Muted" -t 1500
        else
            notify-send "Volume" "Unmuted" -t 1500
        fi
        exit 0
    fi
fi

# If both failed, try to open volume control
if command -v pavucontrol &> /dev/null; then
    pavucontrol &
elif command -v gnome-control-center &> /dev/null; then
    gnome-control-center sound &
elif command -v systemsettings5 &> /dev/null; then
    systemsettings5 kcm_pulseaudio &
else
    notify-send "Volume" "No volume control available" -t 2000
fi
