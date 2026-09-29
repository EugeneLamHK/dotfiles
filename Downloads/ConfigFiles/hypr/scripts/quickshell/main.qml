import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "eq"

Item {
    id: root
    property bool eqVisible: false

    Process {
        id: toggleReader
        command: ["bash", "-c", "mkdir -p ~/.local/state/quickshell; cat ~/.local/state/quickshell/eq_toggle 2>/dev/null || echo 0"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseInt(this.text.trim());
                if (!isNaN(val)) {
                    root.eqVisible = (val === 1);
                }
            }
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            toggleReader.running = false;
            toggleReader.running = true;
        }
    }

    PanelWindow {
        id: eqWindow
        visible: root.eqVisible
        anchors {
            top: true
            right: true
        }
        margins {
            top: 48
            right: 120
        }
        implicitWidth: 700
        implicitHeight: 380
        color: "transparent"

        EqPopup {
            anchors.fill: parent
        }
    }
}
