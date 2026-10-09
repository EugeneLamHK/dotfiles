// Clock.qml — centered clock pill. Click to cycle display modes:
//   mode 0: 09:36
//   mode 1: Fri 09 Oct
//   mode 2: 09:36 Fri 09 Oct
import Quickshell
import QtQuick

Rectangle {
    id: clockPill
    implicitWidth: clockText.implicitWidth + 28
    implicitHeight: 24
    radius: 17
    color: "transparent"

    readonly property bool hovered: hoverArea.containsMouse

    // 0 = time, 1 = date, 2 = both. Click cycles 0 → 1 → 2 → 0.
    property int mode: 0

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: {
            const t = Qt.formatDateTime(clock.date, "HH:mm")
            const dstr = Qt.formatDateTime(clock.date, "ddd dd MMM")
            if (clockPill.mode === 0) return t
            if (clockPill.mode === 1) return dstr
            return t + "  " + dstr
        }
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        font.bold: true
        color: "#ffffff"
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: clockPill.mode = (clockPill.mode + 1) % 3
    }
}
