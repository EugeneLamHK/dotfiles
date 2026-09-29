#!/bin/bash

# Power Saving Mode using Intel P-State EPP
# Sets Energy Performance Preference to "power"
# This is PERSISTENT and won't reset when idle

NUM_CORES=$(nproc)

# Set EPP to power for all cores
for ((i=0; i<$NUM_CORES; i++)); do
    echo "power" | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/energy_performance_preference > /dev/null 2>&1
done

# Set the scaling governor to powersave
for ((i=0; i<$NUM_CORES; i++)); do
    echo "powersave" | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor > /dev/null 2>&1
done

# Optionally disable turbo boost for max power saving
if [[ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
    echo "1" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null 2>&1
fi

# Update state file
echo "power_saving" > "$HOME/.config/waybar/power_mode_state"

# Log the change
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Switched to Power Saving Mode (EPP)" >> "$HOME/.config/waybar/power_mode.log"
