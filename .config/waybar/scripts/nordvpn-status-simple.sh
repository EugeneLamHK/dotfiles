#!/bin/bash
# ── vpn-status-simple.sh ──────────────────────────────────────────────────
# Description: Checks ProtonVPN and NordVPN, shows whichever is connected
# ───────────────────────────────────────────────────────────────────────────

# Helper: check generic VPN interface
has_vpn_interface() {
    ip link show | grep -qE "tun|tap|wg|vpn"
}

# 1. Check ProtonVPN first (user preference)
if command -v protonvpn &> /dev/null; then
    p_status=$(protonvpn status 2>/dev/null | grep -i "status:" | awk '{print $2}')
    if [[ "$p_status" == "Connected" ]]; then
        server=$(protonvpn status 2>/dev/null | grep -i "server:" | awk '{print $2}')
        [[ -z "$server" ]] && server="ON"
        echo "<span foreground='#a6e3a1'>[VPN]: $server</span>"
        exit 0
    fi
fi

# 2. Check NordVPN
if command -v nordvpn &> /dev/null; then
    n_status=$(nordvpn status 2>/dev/null | grep -i "Status:" | awk '{print $2}')
    if [[ "$n_status" == "Connected" ]]; then
        country=$(nordvpn status 2>/dev/null | grep "Country:" | awk '{print $2}')
        [[ -z "$country" ]] && country="ON"
        echo "<span foreground='#a6e3a1'>[VPN]: $country</span>"
        exit 0
    fi
fi

# 3. Fallback: generic interface detection
if has_vpn_interface; then
    country=$(curl -s --max-time 2 ifconfig.co/country 2>/dev/null)
    [[ -z "$country" ]] && country="ACTIVE"
    echo "<span foreground='#a6e3a1'>[VPN]: $country</span>"
else
    echo "<span foreground='#f38ba8'>[VPN]: OFF</span>"
fi
