#!/bin/sh
# vpn-status.sh — prints "up" if the ProtonVPN interface (proton0) exists.
# The QML VPNPill does this inline via Process; this script is provided for
# parity with the old waybar setup and for manual checks.
if ip link show proton0 >/dev/null 2>&1; then
    echo up
else
    echo down
fi
