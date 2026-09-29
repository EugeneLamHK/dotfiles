import QtQuick
import "root:/" as Root

ScriptModule {
    command: "~/.config/waybar/scripts/day_of_week.sh"
    interval: 60
    textColor: Root.Colors.dayOfWeek
    bold: true
    leftPadding: 10
    rightPadding: 10
    hoverColor: Root.Colors.dayOfWeekHoverBg
    tooltipText: "Day of Week"
}
