import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "root:/core"
import "root:/services"

CustomRect {
    id: root
    color: Colors.surface
    anchors.fill: parent

    bottomLeftRadius: 10
    bottomRightRadius: 10
    topLeftRadius: 10
    topRightRadius: 10

    MouseArea {
        id: powerMenuArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            visibilities.powerMenu = true;
        }
        onExited: {
            visibilities.powerMenu = false;
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: Sizing.spacing.small

            MouseArea {
                Layout.alignment: Qt.AlignCenter
                hoverEnabled: true
                implicitWidth: lockIcon.implicitWidth
                implicitHeight: lockIcon.implicitHeight
                MaterialIcon {
                    id: lockIcon
                    name: "lock"
                    size: Fonts.sizing.large
                    color: parent.containsMouse ? Colors.primary : Colors.foreground
                }
                onClicked: {
                    System.lock.running = true;
                }
            }

            MouseArea {
                id: restartArea
                Layout.alignment: Qt.AlignCenter
                hoverEnabled: true
                implicitWidth: restartIcon.implicitWidth
                implicitHeight: restartIcon.implicitHeight
                MaterialIcon {
                    id: restartIcon
                    name: "restart_alt"
                    size: Fonts.sizing.large
                    color: restartArea.containsMouse ? Colors.primary : Colors.foreground
                }
                onClicked: {
                    System.reboot.running = true;
                }
            }

            MouseArea {
                id: powerOffArea
                Layout.alignment: Qt.AlignCenter
                hoverEnabled: true
                implicitWidth: powerIcon.implicitWidth
                implicitHeight: powerIcon.implicitHeight
                onClicked: {
                    System.powerOff.running = true;
                }

                MaterialIcon {
                    id: powerIcon
                    name: "power_settings_new"
                    Layout.alignment: Qt.AlignCenter
                    size: Fonts.sizing.large
                    color: powerOffArea.containsMouse ? Colors.primary : Colors.foreground
                }
            }
        }
    }
}
