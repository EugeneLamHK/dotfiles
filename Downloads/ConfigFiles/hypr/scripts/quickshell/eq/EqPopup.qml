import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    function s(val) {
        var scale = Math.max(0.35, Math.pow(Screen.width / 1920.0, 0.85));
        return Math.round(val * scale);
    }

    property color base: "#1e1e2e"
    property color surface0: "#313244"
    property color surface1: "#45475a"
    property color surface2: "#585b70"
    property color text: "#cdd6f4"
    property color subtext0: "#a6adc8"
    property color overlay0: "#6c7086"
    property color overlay1: "#7f849c"
    property color blue: "#89b4fa"
    property color mauve: "#cba6f7"

    property var eqData: {
        "b1": 0, "b2": 0, "b3": 0, "b4": 0, "b5": 0,
        "b6": 0, "b7": 0, "b8": 0, "b9": 0, "b10": 0,
        "preset": "Flat", "pending": false
    }

    property real lastEqUpdate: 0

    Process {
        id: colorReader
        running: true
        command: ["bash", "-c", "cat ~/.config/hypr/scripts/quickshell/qs_colors.json 2>/dev/null || echo ''"]
        stdout: StdioCollector {
            onStreamFinished: {
                var txt = this.text.trim();
                if (txt === "") return;
                try {
                    var c = JSON.parse(txt);
                    if (c.base) root.base = c.base;
                    if (c.surface0) root.surface0 = c.surface0;
                    if (c.surface1) root.surface1 = c.surface1;
                    if (c.surface2) root.surface2 = c.surface2;
                    if (c.text) root.text = c.text;
                    if (c.subtext0) root.subtext0 = c.subtext0;
                    if (c.overlay0) root.overlay0 = c.overlay0;
                    if (c.overlay1) root.overlay1 = c.overlay1;
                    if (c.blue) root.blue = c.blue;
                    if (c.mauve) root.mauve = c.mauve;
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            colorReader.running = false;
            colorReader.running = true;
        }
    }

    function execCmd(cmdStr) {
        var safeCmd = cmdStr.replace(/`/g, "\\`");
        var p = Qt.createQmlObject('
            import Quickshell.Io
            Process {
                command: ["bash", "-c", "' + safeCmd + '"]
                running: true
                onExited: (exitCode) => destroy()
            }
        ', root);
    }

    function applyPreset(presetName) {
        var presets = {
            "Flat":      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            "Bass":      [5, 7, 5, 2, 1, 0, 0, 0, 1, 2],
            "Mega7":     [1, 0, -1, 1, -1, 0, 1, -2, 1, 0],
            "Vocal":     [-2, -1, 1, 3, 5, 5, 4, 2, 1, 0],
            "Pop":       [2, 4, 2, 0, 1, 2, 4, 2, 1, 2],
            "Rock":      [5, 4, 2, -1, -2, -1, 2, 4, 5, 6],
            "Reference": [-3, 0, 0, 1, 0, -1, 1, 2, -2, 0],
            "Classic":   [0, 1, 2, 2, 2, 2, 1, 2, 3, 4]
        };
        if (presets[presetName]) {
            var temp = Object.assign({}, root.eqData);
            for (var i = 0; i < 10; i++) {
                temp["b" + (i + 1)] = presets[presetName][i];
            }
            temp.preset = presetName;
            temp.pending = false;
            root.eqData = temp;
            root.lastEqUpdate = Date.now();
            root.execCmd("$HOME/.config/hypr/scripts/quickshell/music/equalizer.sh preset " + presetName);
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!eqProc.running) {
                eqProc.running = true;
            }
        }
    }

    Process {
        id: eqProc
        running: true
        command: ["bash", "-c", "$HOME/.config/hypr/scripts/quickshell/music/equalizer.sh get"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (Date.now() - root.lastEqUpdate < 2000) return;
                var out = this.text.trim();
                if (out) {
                    try { root.eqData = JSON.parse(out); } catch(e) {}
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: root.s(20)
        color: root.base
        radius: root.s(14)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.s(20)
            spacing: root.s(15)

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Equalizer"
                    color: root.mauve
                    font.family: "JetBrains Mono"
                    font.pixelSize: root.s(16)
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredHeight: root.s(28)
                    Layout.preferredWidth: applyTxt.width + root.s(30)
                    radius: root.s(10)
                    color: root.eqData.pending ? root.mauve : root.surface1
                    border.color: root.eqData.pending ? root.mauve : root.surface2
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.OutCubic } }

                    Text {
                        id: applyTxt
                        anchors.centerIn: parent
                        text: root.eqData.pending ? "Apply" : "Saved"
                        color: root.eqData.pending ? root.base : root.subtext0
                        font.family: "JetBrains Mono"
                        font.pixelSize: root.s(12)
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: root.eqData.pending ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: {
                            if (root.eqData.pending) {
                                var t = Object.assign({}, root.eqData);
                                t.pending = false;
                                root.eqData = t;
                                root.lastEqUpdate = Date.now();
                                root.execCmd("$HOME/.config/hypr/scripts/quickshell/music/equalizer.sh apply");
                            }
                        }
                    }
                }

                Text {
                    text: root.eqData.preset || "Flat"
                    color: root.subtext0
                    font.family: "JetBrains Mono"
                    font.pixelSize: root.s(14)
                    font.bold: true
                    Layout.leftMargin: root.s(15)
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.s(180)
                Row {
                    id: eqSliderRow
                    anchors.fill: parent
                    Repeater {
                        model: [
                            {"idx": 1, "lbl": "31"},  {"idx": 2, "lbl": "63"},
                            {"idx": 3, "lbl": "125"}, {"idx": 4, "lbl": "250"},
                            {"idx": 5, "lbl": "500"}, {"idx": 6, "lbl": "1k"},
                            {"idx": 7, "lbl": "2k"},  {"idx": 8, "lbl": "4k"},
                            {"idx": 9, "lbl": "8k"},  {"idx": 10, "lbl": "16k"}
                        ]
                        delegate: Item {
                            width: eqSliderRow.width / 10
                            height: eqSliderRow.height
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: root.s(5)
                                Slider {
                                    id: eqSlider
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignHCenter
                                    orientation: Qt.Vertical
                                    from: -12
                                    to: 12
                                    stepSize: 1
                                    Connections {
                                        target: root
                                        function onEqDataChanged() {
                                            if (!eqSlider.pressed && root.eqData && root.eqData["b" + modelData.idx] !== undefined) {
                                                var p = Number(root.eqData["b" + modelData.idx]);
                                                if (!isNaN(p)) eqSlider.value = p;
                                            }
                                        }
                                    }
                                    Behavior on value {
                                        enabled: !eqSlider.pressed
                                        NumberAnimation { duration: 350; easing.type: Easing.OutQuart }
                                    }
                                    onPressedChanged: {
                                        if (!pressed) {
                                            var t = Object.assign({}, root.eqData);
                                            t["b" + modelData.idx] = Math.round(value);
                                            t.preset = "Custom";
                                            t.pending = true;
                                            root.eqData = t;
                                            root.lastEqUpdate = Date.now();
                                            root.execCmd("$HOME/.config/hypr/scripts/quickshell/music/equalizer.sh set_band " + modelData.idx + " " + Math.round(value));
                                        }
                                    }
                                    background: Rectangle {
                                        x: eqSlider.leftPadding + (eqSlider.availableWidth - width) / 2
                                        y: eqSlider.topPadding
                                        width: root.s(10)
                                        height: eqSlider.availableHeight
                                        radius: root.s(4)
                                        color: Qt.rgba(root.surface0.r, root.surface0.g, root.surface0.b, 0.7)
                                        Rectangle {
                                            width: parent.width
                                            height: (1 - eqSlider.visualPosition) * parent.height
                                            y: eqSlider.visualPosition * parent.height
                                            radius: root.s(4)
                                            color: root.blue
                                        }
                                    }
                                    handle: Rectangle {
                                        x: eqSlider.leftPadding + (eqSlider.availableWidth - width) / 2
                                        y: eqSlider.topPadding + eqSlider.visualPosition * (eqSlider.availableHeight - height)
                                        width: root.s(18)
                                        height: root.s(18)
                                        radius: root.s(9)
                                        color: root.text
                                    }
                                }
                                Text {
                                    text: modelData.lbl
                                    color: root.overlay1
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: root.s(10)
                                    font.bold: true
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: root.s(8)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: root.s(10)
                    Repeater {
                        model: ["Flat", "Bass", "Mega7", "Vocal"]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: root.s(32)
                            radius: root.s(8)
                            property bool isActive: root.eqData && root.eqData.preset === modelData
                            property bool isHovered: hoverMa.containsMouse
                            color: isActive ? root.mauve : (isHovered ? root.surface1 : "#1E1E2E")
                            scale: isHovered && !isActive ? 1.05 : 1.0
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: parent.isActive ? root.base : (parent.isHovered ? root.text : root.subtext0)
                                font.family: "JetBrains Mono"
                                font.pixelSize: root.s(12)
                                font.bold: true
                            }
                            MouseArea {
                                id: hoverMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.applyPreset(modelData)
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: root.s(10)
                    Repeater {
                        model: ["Pop", "Rock", "Reference", "Classic"]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: root.s(32)
                            radius: root.s(8)
                            property bool isActive: root.eqData && root.eqData.preset === modelData
                            property bool isHovered: hoverMa.containsMouse
                            color: isActive ? root.mauve : (isHovered ? root.surface1 : "#1E1E2E")
                            scale: isHovered && !isActive ? 1.05 : 1.0
                            Behavior on color { ColorAnimation { duration: 200 } }
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: parent.isActive ? root.base : (parent.isHovered ? root.text : root.subtext0)
                                font.family: "JetBrains Mono"
                                font.pixelSize: root.s(12)
                                font.bold: true
                            }
                            MouseArea {
                                id: hoverMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.applyPreset(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
