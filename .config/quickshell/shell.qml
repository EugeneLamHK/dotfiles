import Quickshell
import QtQuick
import "root:/" as Root
import "osd"

Scope {
    Root.MediaPlayer {}
    Root.Bar {}
    OSD {}  // Volume & Brightness pop-up OSDs (Persona-style)

    Connections {
        target: Quickshell
        function onReloadCompleted() {
            // suppresses the default "Config reloaded" popup
        }
        function onReloadFailed(errorString) {
            // suppresses the default error popup
        }
    }
}
