import QtQuick
import "root:/" as Root

ScriptModule {
    command: "~/.config/waybar/scripts/arch_icon.sh"
    interval: 86400
    textColor: Root.Colors.arch
    fontSize: Root.Colors.fontSizeLarge
    leftPadding: 15
    rightPadding: 4
    hoverColor: Root.Colors.archHoverBg
    clickCommand: "qs ipc call mediaplayer toggle"
}
