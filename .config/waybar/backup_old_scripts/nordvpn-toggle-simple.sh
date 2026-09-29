#!/bin/bash
# ── nordvpn-toggle-simple.sh ──────────────────────────────────────────────
# Description: Simple VPN toggle that works with NordVPN or shows settings
# Usage: Called by Waybar `custom/vpn` on click
# Dependencies: nordvpn CLI or network manager
# ───────────────────────────────────────────────────────────────────────────

# Check if nordvpn command exists
if command -v nordvpn &> /dev/null; then
    # Use NordVPN CLI if available
    status=$(nordvpn status 2>/dev/null | grep "Status:" | awk '{print $2}')
    if [[ "$status" == "Connected" ]]; then
        nordvpn disconnect
        notify-send "VPN" "Disconnected from NordVPN" -t 2000
    else
        nordvpn connect
        notify-send "VPN" "Connecting to NordVPN..." -t 2000
    fi
else
    # Fallback: Open network settings
    if command -v nm-connection-editor &> /dev/null; then
        nm-connection-editor &
    elif command -v gnome-control-center &> /dev/null; then
        gnome-control-center network &
    elif command -v systemsettings5 &> /dev/null; then
        systemsettings5 kcm_networkmanagement &
    else
        notify-send "VPN" "No VPN client found. Install NordVPN CLI or configure manually." -t 3000
    fi
fi
