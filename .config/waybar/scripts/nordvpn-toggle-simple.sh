#!/bin/bash
# ── vpn-toggle-simple.sh ──────────────────────────────────────────────────
# Description: Disconnects any active VPN, or connects ProtonVPN by default
# ───────────────────────────────────────────────────────────────────────────

# Check if ProtonVPN is connected
p_connected=false
if command -v protonvpn &> /dev/null; then
    p_status=$(protonvpn status 2>/dev/null | grep -i "status:" | awk '{print $2}')
    [[ "$p_status" == "Connected" ]] && p_connected=true
fi

# Check if NordVPN is connected
n_connected=false
if command -v nordvpn &> /dev/null; then
    n_status=$(nordvpn status 2>/dev/null | grep -i "Status:" | awk '{print $2}')
    [[ "$n_status" == "Connected" ]] && n_connected=true
fi

# Disconnect whichever is active
if [[ "$p_connected" == true ]]; then
    protonvpn disconnect
    notify-send "VPN" "Disconnected from ProtonVPN" -t 2000
    exit 0
elif [[ "$n_connected" == true ]]; then
    nordvpn disconnect
    notify-send "VPN" "Disconnected from NordVPN" -t 2000
    exit 0
fi

# Nothing connected — connect ProtonVPN (user preference)
if command -v protonvpn &> /dev/null; then
    protonvpn connect
    notify-send "VPN" "Connecting to ProtonVPN..." -t 2000
elif command -v nordvpn &> /dev/null; then
    nordvpn connect
    notify-send "VPN" "Connecting to NordVPN..." -t 2000
else
    notify-send "VPN" "No VPN client found." -t 3000
fi
