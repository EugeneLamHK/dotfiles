#!/bin/bash
# ── brightness_icon.sh ─────────────────────────────────────────────────────
# Description: Shows brightness icon with color coding based on level
# Usage: Waybar `custom/brightness` every 2s
# Dependencies: brightnessctl
# Colors: 100%=yellow, 75%=orange, 50%=pink, 25%=red
# ───────────────────────────────────────────────────────────────────────────

# Check if brightnessctl is available
if ! command -v brightnessctl &> /dev/null; then
    echo '{"text": "󰃞", "tooltip": "brightnessctl not found", "class": "error"}'
    exit 1
fi

# Get brightness percentage
brightness=$(brightnessctl get 2>/dev/null)
max_brightness=$(brightnessctl max 2>/dev/null)

if [ -z "$brightness" ] || [ -z "$max_brightness" ] || [ "$max_brightness" -eq 0 ]; then
    echo '{"text": "󰃞", "tooltip": "Cannot read brightness", "class": "error"}'
    exit 1
fi

percent=$((brightness * 100 / max_brightness))

# Choose icon and color based on brightness level
if [ "$percent" -ge 90 ]; then
    icon="󰃠"
    class="brightness-100"  # yellow
elif [ "$percent" -ge 65 ]; then
    icon="󰃟"
    class="brightness-75"   # orange
elif [ "$percent" -ge 40 ]; then
    icon="󰃟"
    class="brightness-50"   # pink
elif [ "$percent" -ge 15 ]; then
    icon="󰃞"
    class="brightness-25"   # red
else
    icon="󰃞"
    class="brightness-low"  # red
fi

# Create tooltip
tooltip="Brightness: ${percent}%\nScroll to adjust\nClick for settings"

# Output JSON for Waybar
echo "{\"text\": \"$icon\", \"tooltip\": \"$tooltip\", \"class\": \"$class\", \"percentage\": $percent}"
