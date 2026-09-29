// Volume & Brightness OSD — Persona-style rounded bar popups
// Adapted from https://github.com/Yujonpradhananga/Persona-Quickshell

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    // ===== OSD Colors (clean transparent + white) =====
    // Bar background: semi-transparent dark, no color tint
    readonly property color osdBarBg: "#CC1a1b26"
    // Track background: faint white
    readonly property color osdTrackBg: "#33415c"
    // Fill: white
    readonly property color osdFill: "#ffffff"
    // Text & icon: white
    readonly property color osdText: "#ffffff"
    readonly property color osdIcon: "#ffffff"
    readonly property string osdFont: "JetBrainsMono Nerd Font"

    // ===== OSD Size (40% smaller than original) =====
    readonly property int osdWidth: 330
    readonly property int osdHeight: 30

    // ===== Volume State =====
    property bool showVolume: false
    property real volumeValue: 0
    property bool volumeMuted: false

    // ===== Brightness State =====
    property bool showBrightness: false
    property int brightnessPercent: 0
    property int _brightnessCurrent: -1
    property int _brightnessMax: 1
    property bool _brightnessInitialized: false
    property string backlightDevice: ""

    // ===== Pipewire Volume Tracking =====
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null
        enabled: target !== null

        function onVolumeChanged() {
            root.volumeValue = Pipewire.defaultAudioSink.audio.volume;
            root.showVolume = true;
            volumeHideTimer.restart();
        }

        function onMutedChanged() {
            root.volumeMuted = Pipewire.defaultAudioSink.audio.muted;
            root.showVolume = true;
            volumeHideTimer.restart();
        }
    }

    Timer {
        id: volumeHideTimer
        interval: 1000
        onTriggered: root.showVolume = false
    }

    // ===== Brightness Tracking (sysfs polling) =====
    Process {
        id: findBacklight
        command: ["sh", "-c", "ls /sys/class/backlight | head -n 1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let device = data.trim();
                if (device) {
                    root.backlightDevice = device;
                }
            }
        }
    }

    Timer {
        id: brightnessPollTimer
        interval: 100
        running: root.backlightDevice !== ""
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            brightnessCurrentFile.reload();
            brightnessMaxFile.reload();
        }
    }

    FileView {
        id: brightnessCurrentFile
        path: root.backlightDevice
            ? "/sys/class/backlight/" + root.backlightDevice + "/brightness"
            : ""
        onLoaded: {
            var val = parseInt(text().trim());
            if (isNaN(val))
                return;
            if (root._brightnessCurrent !== val) {
                if (root._brightnessInitialized && root._brightnessCurrent !== -1) {
                    root.showBrightness = true;
                    brightnessHideTimer.restart();
                }
                root._brightnessCurrent = val;
                root._updateBrightnessPercent();
                root._brightnessInitialized = true;
            }
        }
    }

    FileView {
        id: brightnessMaxFile
        path: root.backlightDevice
            ? "/sys/class/backlight/" + root.backlightDevice + "/max_brightness"
            : ""
        onLoaded: {
            var val = parseInt(text().trim());
            if (!isNaN(val)) {
                root._brightnessMax = val;
                root._updateBrightnessPercent();
            }
        }
    }

    function _updateBrightnessPercent() {
        if (root._brightnessMax > 0 && root._brightnessCurrent >= 0) {
            root.brightnessPercent = Math.round(
                (root._brightnessCurrent / root._brightnessMax) * 100
            );
        }
    }

    Timer {
        id: brightnessHideTimer
        interval: 1000
        onTriggered: root.showBrightness = false
    }

    // ===== Shared OSD Bar Component =====
    component OsdBar: PanelWindow {
        id: barRoot
        property alias iconText: iconLabel.text
        property alias percentText: percentLabel.text
        property real fillRatio: 0

        anchors.top: true
        margins.top: screen.height / 9
        exclusiveZone: 0
        WlrLayershell.layer: WlrLayer.Overlay

        implicitWidth: root.osdWidth
        implicitHeight: root.osdHeight
        color: "transparent"
        mask: Region {}

        // Pill-shaped bar — semi-transparent blue (Persona style)
        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: root.osdBarBg

            RowLayout {
                anchors {
                    fill: parent
                    leftMargin: 10
                    rightMargin: 10
                }
                spacing: 8

                // Icon — literal Nerd Font characters (NOT \u escapes)
                Text {
                    id: iconLabel
                    color: root.osdIcon
                    font.pixelSize: 14
                    font.family: root.osdFont
                    Layout.alignment: Qt.AlignVCenter
                }

                // Progress track — lighter blue
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 6
                    radius: 20
                    color: root.osdTrackBg

                    // Filled portion — white (Persona style)
                    Rectangle {
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        implicitWidth: parent.width * barRoot.fillRatio
                        radius: parent.radius
                        color: root.osdFill
                    }
                }

                // Percentage
                Text {
                    id: percentLabel
                    color: root.osdText
                    font.pixelSize: 12
                    font.family: root.osdFont
                    font.weight: Font.Bold
                    Layout.minimumWidth: 38
                    horizontalAlignment: Text.AlignRight
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }

    // ===== Volume OSD Instance =====
    // Icons use literal UTF-8 characters — \u escapes break for Nerd Fonts
    LazyLoader {
        active: root.showVolume

        OsdBar {
            iconText: {
                var vol = Math.round(root.volumeValue * 100);
                if (root.volumeMuted || vol === 0) return "󰖁";
                if (vol < 30)                         return "󰕿";
                if (vol < 70)                         return "󰖀";
                                                      return "󰕾";
            }
            percentText: Math.round(root.volumeValue * 100) + "%"
            fillRatio: root.volumeValue
        }
    }

    // ===== Brightness OSD Instance =====
    LazyLoader {
        active: root.showBrightness

        OsdBar {
            iconText: {
                if (root.brightnessPercent === 0)     return "󰃞";
                if (root.brightnessPercent < 30)      return "󰃟";
                if (root.brightnessPercent < 60)      return "󰃠";
                if (root.brightnessPercent < 85)      return "󰃡";
                                                      return "󰃢";
            }
            percentText: root.brightnessPercent + "%"
            fillRatio: root.brightnessPercent / 100
        }
    }
}
