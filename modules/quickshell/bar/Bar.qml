import Quickshell
import QtQuick
import QtQuick.Controls
import "root:/core"
import "root:/bar/components"
import "root:/services"

CustomRect {
    id: root
    required property ShellScreen screen
    required property PersistentProperties visibilities
    implicitWidth: Sizing.barWidth
    implicitHeight: screen.height
    color: Colors.background

    BarIcon {
        id: networkIcon
        visibility: visibilities.networkMenu
        iconName: {
            const strength = Network.currentNetwork?.strength;
            if (strength === undefined) {
                return "wifi_lock";
            } else if (strength >= 75) {
                return "network_wifi_4_bar";
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
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: powerIcon.top
        }
        implicitWidth: 60
        implicitHeight: 60
    }

    BarIcon {
        id: powerIcon
        visibility: visibilities.powerMenu
        iconName: "settings_power"
        setVisibility: visible => {
            visibilities.powerMenu = visible;
        }
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        implicitWidth: 60
        implicitHeight: 60
    }
}
