#!/bin/bash

# Power Mode Toggle Script
# Cycles through performance, balanced, and power saving modes using Intel EPP

STATE_FILE="$HOME/.config/waybar/power_mode_state"
SCRIPTS_DIR="$HOME/.config/waybar/scripts"

# Initialize state file if it doesn't exist
if [[ ! -f "$STATE_FILE" ]]; then
    echo "balanced" > "$STATE_FILE"
fi

# Read current mode
CURRENT_MODE=$(cat "$STATE_FILE")

# Cycle to next mode
case "$CURRENT_MODE" in
    performance)
        # Switch to balanced
        bash "$SCRIPTS_DIR/set_balanced_mode.sh"
        ;;
    balanced)
        # Switch to power saving
        bash "$SCRIPTS_DIR/set_power_saving_mode.sh"
        ;;
    power_saving)
        # Switch to performance
        bash "$SCRIPTS_DIR/set_performance_mode.sh"
        ;;
    *)
        # Default to balanced
        bash "$SCRIPTS_DIR/set_balanced_mode.sh"
        ;;
esac
