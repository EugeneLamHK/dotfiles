// BatteryBar.qml — battery progress-bar pill driven by UPower (event-driven,
// no polling). Plays a short shimmer sweep across the fill when the charger is
// plugged in, then settles to a static fill (battery-friendly).
import Quickshell
import Quickshell.Services.UPower
import QtQuick

Rectangle {
    id: root
    implicitWidth: 120
    implicitHeight: 22
    radius: 17
    color: "transparent"

    readonly property var device: UPower.displayDevice
    readonly property bool hasBattery: device && device.isLaptopBattery
    readonly property real pct: device ? device.percentage : 0
    readonly property bool charging: device !== null
        && (device.state === UPowerDeviceState.Charging
            || device.state === UPowerDeviceState.PendingCharge)
    readonly property bool low: pct < 0.20 && !charging

    visible: hasBattery
    width: hasBattery ? implicitWidth : 0

    // Fill color: accent normally, red-ish below 20% (declarative binding).
    readonly property color fillColor: low ? Colors.danger : "#ffffff"

    Row {
        anchors.centerIn: parent
        spacing: 6

        // Bolt icon while charging
        Text {
            visible: root.charging
            text: "\uf0e7" // nf-fa-bolt
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            color: "#ffd700"
            anchors.verticalCenter: parent.verticalCenter
        }

        // Progress track
        Rectangle {
            id: track
            width: 96
            height: 5
            radius: 2.5
            color: Qt.rgba(1, 1, 1, 0.28)   // translucent track: drained portion stays visible
            anchors.verticalCenter: parent.verticalCenter
            clip: true

            // Static fill (declarative width binding; clamped so rounding is sane)
            Rectangle {
                id: fill
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: Math.max(root.pct, 0.06) * track.width
                radius: 7
                color: root.fillColor
                Behavior on color { ColorAnimation { duration: 300 } }
                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            }

            // Shimmer sweep (only visible/animated during plug-in wave)
            Rectangle {
                id: shimmer
                width: track.width * 0.45
                height: track.height
                radius: 7
                visible: sweep.running
                x: -width
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop {
                        position: 0.5
                        color: Qt.rgba(1, 1, 1, 0.35)
                    }
                    GradientStop { position: 1.0; color: "transparent" }
                }

                // A few sweeps (~4.5s total), then stops by itself.
                SequentialAnimation {
                    id: sweep
                    loops: 3
                    NumberAnimation {
                        target: shimmer
                        property: "x"
                        from: -shimmer.width
                        to: track.width
                        duration: 1500
                        easing.type: Easing.InOutSine
                    }
                    onFinished: shimmer.x = -shimmer.width
                }
            }
        }

    }

    // Trigger the shimmer once per transition to charging (plug-in event).
    property bool wasCharging: false
    onChargingChanged: {
        if (charging && !wasCharging) {
            sweep.stop();
            shimmer.x = -shimmer.width;
            sweep.start();
        }
        wasCharging = charging;
    }
    Component.onCompleted: wasCharging = charging
}
