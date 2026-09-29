#!/bin/bash

# Performance Mode using Intel P-State EPP
# Sets Energy Performance Preference to "performance"
# This is PERSISTENT and won't reset when idle

NUM_CORES=$(nproc)

# Set EPP to performance for all cores
for ((i=0; i<$NUM_CORES; i++)); do
    echo "performance" | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/energy_performance_preference > /dev/null 2>&1
done

# Also set the scaling governor to performance
for ((i=0; i<$NUM_CORES; i++)); do
    echo "performance" | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor > /dev/null 2>&1
done

# Disable turbo boost limit (allow max frequency)
if [[ -f /sys/devices/system/cpu/intel_pstate/no_turbo ]]; then
    echo "0" | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo > /dev/null 2>&1
fi

# Update state file
echo "performance" > "$HOME/.config/waybar/power_mode_state"

# Log the change
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Switched to Performance Mode (EPP)" >> "$HOME/.config/waybar/power_mode.log"
