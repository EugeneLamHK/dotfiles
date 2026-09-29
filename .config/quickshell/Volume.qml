import QtQuick
import "root:/" as Root

ScriptModule {
    command: "~/.config/waybar/scripts/volume_icon.sh"
    interval: 2
    textColor: Root.Colors.volume
    leftPadding: 10
    rightPadding: 10
    hoverColor: Root.Colors.volumeHoverBg
    clickCommand: "~/.config/waybar/scripts/volume-toggle.sh"
    scrollUpCommand: "pactl set-sink-volume @DEFAULT_SINK@ +5% || amixer set Master 5%+"
    scrollDownCommand: "pactl set-sink-volume @DEFAULT_SINK@ -5% || amixer set Master 5%-"
    tooltipText: "Volume - Click to mute/unmute, Scroll to adjust"
}
