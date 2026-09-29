#!/bin/bash

# Power Saving Mode: 2.2GHz, 60Hz
# Requires: cpupower, swaymsg

CONFIG_FILE="$HOME/.config/waybar/power_mode_config.sh"
source "$CONFIG_FILE"

# CPU Frequency: 2.2 GHz = 2200000 kHz
CPU_FREQ_KHZ=2200000

# Set CPU frequency using cpupower
if [[ "$CPU_CONTROL_METHOD" == "cpupower" ]]; then
    # Set max frequency for all cores
    for ((i=0; i<$NUM_CORES; i++)); do
        cpupower -c $i frequency-set -u ${CPU_FREQ_KHZ}k 2>/dev/null || true
    done
    
    # Disable turbo boost for Intel (power saving mode)
    if [[ "$SCALING_DRIVER" == "intel_pstate" ]]; then
        echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null || true
    fi
elif [[ "$CPU_CONTROL_METHOD" == "sysfs" ]]; then
    # Direct sysfs method
    for ((i=0; i<$NUM_CORES; i++)); do
        echo $CPU_FREQ_KHZ > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq 2>/dev/null || true
    done
fi

# Set display refresh rate to 60Hz using swaymsg
if [[ "$DISPLAY_TOOL" == "swaymsg" ]]; then
    swaymsg output "$DISPLAY_NAME" mode 1920x1200@60Hz 2>/dev/null || \
    swaymsg output "$DISPLAY_NAME" mode 1920x1080@60Hz 2>/dev/null || \
    swaymsg output "$DISPLAY_NAME" refresh 60 2>/dev/null || true
elif [[ "$DISPLAY_TOOL" == "wlr-randr" ]]; then
    wlr-randr --output "$DISPLAY_NAME" --mode 1920x1200@60 2>/dev/null || \
    wlr-randr --output "$DISPLAY_NAME" --mode 1920x1080@60 2>/dev/null || true
elif [[ "$DISPLAY_TOOL" == "hyprctl" ]]; then
    hyprctl keyword monitor "$DISPLAY_NAME",1920x1200@60,0x0,1 2>/dev/null || \
    hyprctl keyword monitor "$DISPLAY_NAME",1920x1080@60,0x0,1 2>/dev/null || true
fi

# Log the change
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Switched to Power Saving Mode (2.2GHz, 60Hz)" >> "$HOME/.config/waybar/power_mode.log"
