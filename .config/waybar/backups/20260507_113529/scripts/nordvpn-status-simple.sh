#!/bin/bash
# ── nordvpn-status-simple.sh ──────────────────────────────────────────────
# Description: Simple VPN status checker that works with any VPN
# Usage: Called by Waybar `custom/vpn` every 5s
# Dependencies: ip, curl (optional)
# ───────────────────────────────────────────────────────────────────────────

# Check if nordvpn command exists
if command -v nordvpn &> /dev/null; then
    # Use NordVPN CLI if available
    status=$(nordvpn status 2>/dev/null | grep "Status:" | awk '{print $2}')
    if [[ "$status" == "Connected" ]]; then
        country=$(nordvpn status 2>/dev/null | grep "Country:" | awk '{print $2}')
        [[ -z "$country" ]] && country="UNKNOWN"
        echo "<span foreground='#a6e3a1'>[VPN]: $country</span>"
    else
        echo "<span foreground='#f38ba8'>[VPN]: OFF</span>"
    fi
else
    # Fallback: Check for common VPN interfaces
    if ip route | grep -q "tun\|tap\|wg\|vpn" 2>/dev/null; then
        # Try to get country from external service
        country=$(curl -s --max-time 3 ifconfig.co/country 2>/dev/null)
        [[ -z "$country" ]] && country="ACTIVE"
        echo "<span foreground='#a6e3a1'>[VPN]: $country</span>"
    else
        echo "<span foreground='#f38ba8'>[VPN]: OFF</span>"
    fi
fi
