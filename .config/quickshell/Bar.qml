// Bar.qml — v2 status bar.
// Layout:  LEFT  = Arch icon + VPN pill + Workspaces
//          CENTER = Clock
//          RIGHT  = BatteryBar pill
import Quickshell
import QtQuick
import QtQuick.Layouts

Scope {
    Launcher { id: launcher }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 30
            color: "transparent"

            margins {
                top: 0
                left: 0
                right: 0
            }

            Rectangle {
                id: barRoot
                anchors.fill: parent
                radius: 0
                color: "transparent"

                // ---- LEFT group ----
                Row {
                    id: leftGroup
                    anchors {
                        left: parent.left
                        leftMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 10

                    Workspaces {
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // ---- CENTER clock ----
                Clock {
                    anchors.centerIn: parent
                }

                // ---- RIGHT group: VPN icon + battery ----
                Row {
                    anchors {
                        right: parent.right
                        rightMargin: 12
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 10

                    VPNIcon {
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    BatteryBar {
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
