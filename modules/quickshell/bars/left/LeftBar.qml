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
    implicitWidth: Sizing.leftBarWidth
    implicitHeight: screen.height * 0.75
    color: Colors.background
    radius: Sizing.radius.large
    border.color: Colors.darkSurface
    border.width: 1

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
            implicitHeight: Sizing.meter.height
        }

        Ram.Content {
            Layout.alignment: Qt.AlignCenter
            implicitHeight: Sizing.meter.height
        }

        Volume.Content {
            Layout.alignment: Qt.AlignCenter
            implicitHeight: Sizing.meter.height
        }

        SystemTray.Content {
            id: systemTray
            Layout.alignment: Qt.AlignCenter
        }

        BarIcon {
            id: networkIcon
            visibility: visibilities.networkMenu
            iconName: {
                if (Network.vpnConnected) return "vpn_lock";
                if (Network.ethernetConnected) return "settings_ethernet";
                if (!Network.wifiEnabled) return "wifi_off";
                
                const current = Network.connections.find(c => c.active && (c.type.includes("wireless") || c.type.includes("wifi")));
                if (!current) return "signal_wifi_0_bar";
                
                const wifi = Network.wifiScanResults.find(w => w.ssid === current.name);
                const strength = wifi ? wifi.strength : 100;

                if (strength >= 80) return "wifi";
                if (strength >= 60) return "wifi_2_bar";
                if (strength >= 40) return "wifi_1_bar";
                return "signal_wifi_bad";
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
