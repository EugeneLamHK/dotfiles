#!/bin/bash

# Power Mode Status Display Script for Waybar
# Shows current power mode with Nerd Font icons (proper Unicode)

STATE_FILE="$HOME/.config/waybar/power_mode_state"

# Initialize state file if it doesn't exist
if [[ ! -f "$STATE_FILE" ]]; then
    echo "balanced" > "$STATE_FILE"
fi

# Read current mode
CURRENT_MODE=$(cat "$STATE_FILE")

# Nerd Font Unicode characters
# Bolt: U+F0E7 (nf-fa-bolt)
# Balance Scale: U+F24E (nf-fa-balance_scale)  
# Leaf: U+F06C (nf-fa-leaf)

case "$CURRENT_MODE" in
    performance)
        # Nerd Font bolt icon
        printf '{"text": "\uf0e7", "class": "performance", "tooltip": "Performance Mode (4.7GHz, 120Hz)"}\n'
        ;;
    balanced)
        # Nerd Font balance scale icon
        printf '{"text": "\uf24e", "class": "balanced", "tooltip": "Balanced Mode (3.7GHz, 120Hz)"}\n'
        ;;
    power_saving)
        # Nerd Font leaf icon
        printf '{"text": "\uf06c", "class": "power-saving", "tooltip": "Power Saving Mode (2.2GHz, 60Hz)"}\n'
        ;;
    *)
        # Default to balanced
        printf '{"text": "\uf24e", "class": "balanced", "tooltip": "Balanced Mode (3.7GHz, 120Hz)"}\n'
        ;;
esac
