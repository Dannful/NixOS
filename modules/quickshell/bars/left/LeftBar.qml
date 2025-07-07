import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/core"
import "root:/bars/left/components"
import "root:/bars/left/components/tray" as SystemTray
import "root:/bars/left/components/ram" as Ram
import "root:/bars/left/components/cpu" as Cpu
import "root:/bars/left/components/volume" as Volume
import "root:/services"

CustomRect {
    id: root
    required property ShellScreen screen
    required property PersistentProperties visibilities
    implicitWidth: Sizing.barWidth
    implicitHeight: screen.height * 0.75
    color: Colors.background
    radius: Sizing.radius.large

    property alias powerIcon: powerIcon
    property alias networkIcon: networkIcon

    function getY(target, reference) {
        return column.y + reference.y + reference.implicitHeight - target.implicitHeight + root.y;
    }

    function getX(reference) {
        return reference.x + column.implicitWidth;
    }

    ColumnLayout {
        id: column
        spacing: Sizing.margins.xlarge
        anchors {
            bottom: parent.bottom
            bottomMargin: Sizing.margins.xlarge
        }

        Cpu.Content {
            Layout.alignment: Qt.AlignCenter
            implicitWidth: Sizing.meter.width
            barHeight: Sizing.meter.height
        }

        Ram.Content {
            Layout.alignment: Qt.AlignCenter
            implicitWidth: Sizing.meter.width
            barHeight: Sizing.meter.height
        }

        Volume.Content {
            Layout.alignment: Qt.AlignCenter
            implicitWidth: Sizing.meter.width
            barHeight: Sizing.meter.height
        }

        SystemTray.Content {
            id: systemTray
            Layout.alignment: Qt.AlignCenter
        }

        BarIcon {
            id: networkIcon
            visibility: visibilities.networkMenu
            iconName: {
                const strength = Network.currentNetwork?.strength;
                if (strength === undefined) {
                    return "wifi_lock";
                } else if (strength >= 75) {
                    return "signal_wifi_4_bar";
                } else if (strength >= 50) {
                    return "network_wifi_3_bar";
                } else if (strength >= 25) {
                    return "network_wifi_2_bar";
                } else {
                    return "network_wifi_1_bar";
                }
            }
            setVisibility: visible => {
                visibilities.networkMenu = visible;
            }
        }

        BarIcon {
            id: powerIcon
            visibility: visibilities.powerMenu
            iconName: "settings_power"
            setVisibility: visible => {
                visibilities.powerMenu = visible;
            }
        }
    }
}
