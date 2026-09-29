import QtQuick
import "root:/" as Root

ScriptModule {
    command: "~/.config/waybar/scripts/brightness_icon.sh"
    interval: 2
    parseJson: true
    leftPadding: 10
    rightPadding: 10
    hoverColor: Root.Colors.brightnessHoverBg
    clickCommand: "~/.config/waybar/scripts/brightness-toggle.sh"
    scrollUpCommand: "brightnessctl set +5%"
    scrollDownCommand: "brightnessctl set 5%-"
    tooltipText: "Battery Status"

    textColor: {
        switch (className) {
            case "brightness-100": return Root.Colors.brightness100
            case "brightness-75":  return Root.Colors.brightness75
            case "brightness-50":  return Root.Colors.brightness50
            case "brightness-25":
            case "brightness-low": return Root.Colors.brightness25
            case "error":          return Root.Colors.brightnessError
            default:                return Root.Colors.foreground
        }
    }
}
