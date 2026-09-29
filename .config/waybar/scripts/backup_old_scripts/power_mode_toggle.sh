#!/bin/bash

# Power Mode Toggle Script for Waybar
# Cycles through: Performance -> Balanced -> Power Saving -> Performance

# Source configuration
CONFIG_FILE="$HOME/.config/waybar/power_mode_config.sh"
STATE_FILE="$HOME/.config/waybar/power_mode_state"

if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Initialize state file if it doesn't exist
if [[ ! -f "$STATE_FILE" ]]; then
    echo "balanced" > "$STATE_FILE"
fi

# Read current mode
CURRENT_MODE=$(cat "$STATE_FILE")

# Determine next mode
case "$CURRENT_MODE" in
    performance)
        NEXT_MODE="balanced"
        ;;
    balanced)
        NEXT_MODE="power_saving"
        ;;
    power_saving)
        NEXT_MODE="performance"
        ;;
    *)
        NEXT_MODE="balanced"
        ;;
esac

# Apply the mode
case "$NEXT_MODE" in
    performance)
        # Performance mode: 4.7GHz, 120Hz
        if [[ "$SUDO_REQUIRED" == "true" ]]; then
            sudo "$HOME/.config/waybar/scripts/set_performance_mode.sh"
        else
            "$HOME/.config/waybar/scripts/set_performance_mode.sh"
        fi
        ;;
    balanced)
        # Balanced mode: 3.7GHz, 120Hz
        if [[ "$SUDO_REQUIRED" == "true" ]]; then
            sudo "$HOME/.config/waybar/scripts/set_balanced_mode.sh"
        else
            "$HOME/.config/waybar/scripts/set_balanced_mode.sh"
        fi
        ;;
    power_saving)
        # Power Saving mode: 2.2GHz, 60Hz
        if [[ "$SUDO_REQUIRED" == "true" ]]; then
            sudo "$HOME/.config/waybar/scripts/set_power_saving_mode.sh"
        else
            "$HOME/.config/waybar/scripts/set_power_saving_mode.sh"
        fi
        ;;
esac

# Save new state
echo "$NEXT_MODE" > "$STATE_FILE"
