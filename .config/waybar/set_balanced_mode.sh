#!/bin/bash

# Balanced Mode using Intel P-State EPP
# Sets Energy Performance Preference to "balance_performance"
# This is PERSISTENT and won't reset when idle

NUM_CORES=$(nproc)

# Set EPP to balance_performance for all cores
for ((i=0; i<$NUM_CORES; i++)); do
    echo "balance_performance" | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/energy_performance_preference > /dev/null 2>&1
done

# Set the scaling governor to powersave (intel_pstate manages frequency dynamically)
for ((i=0; i<$NUM_CORES; i++)); do
    echo "powersave" | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor > /dev/null 2>&1
done

# Enable turbo boost
if [[ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
    echo "0" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null 2>&1
fi

# Update state file
echo "balanced" > "$HOME/.config/waybar/power_mode_state"

# Log the change
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Switched to Balanced Mode (EPP)" >> "$HOME/.config/waybar/power_mode.log"
