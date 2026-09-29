import QtQuick
import "root:/" as Root

ScriptModule {
    command: "~/.config/waybar/scripts/nordvpn-status-simple.sh"
    interval: 2
    bold: true
    fontSize: Root.Colors.fontSize
    leftPadding: 0
    rightPadding: 10
    hoverColor: Root.Colors.vpnHoverBg
    clickCommand: "~/.config/waybar/scripts/nordvpn-toggle-simple.sh"
    tooltipText: "Click to toggle VPN connection or open network settings"

    textColor: {
        let txt = displayText.toLowerCase()
        if (txt.length === 0) return "#aaaaaa"
        if (txt.includes("off") || txt.includes("disconnected") || txt.includes("inactive"))
            return "#E35644"
        return "#8DCF72"
    }
}
