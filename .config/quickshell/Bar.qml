import Quickshell
import QtQuick
import QtQuick.Layouts
import "root:/" as Root

Scope {
    id: root

    Launcher { id: launcher }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 34
            color: Root.Colors.barBackground

            Item {
                anchors.fill: parent

                RowLayout {
                    id: leftGroup
                    anchors {
                        left: parent.left
                        leftMargin: 4
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 0
                    ArchIcon {}
                    VPN {}
                }

                Workspaces {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                }

                RowLayout {
                    id: rightGroup
                    anchors {
                        right: parent.right
                        rightMargin: 10
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: 0
                    Brightness {}
                    DayOfWeek {}
                    Battery {}
                    Volume {}
                }
            }
        }
    }
}
