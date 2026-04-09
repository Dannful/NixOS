import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "root:/core"
import "root:/bars/left/components"
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

    property var responsiveSizing: Sizing.ResponsiveLeftBar {
        screenHeight: screen.height
    }

    property alias powerIcon: powerIcon
    property alias networkIcon: networkIcon

    function getY(target, reference) {
        // Position menu aligned with icon, but ensure it doesn't go above top bar area
        const iconBottom = column.y + reference.y + reference.implicitHeight + root.y;
        const menuTop = iconBottom - target.implicitHeight;
        const minY = Sizing.topBarHeight + Sizing.margins.small; // Below top bar
        return Math.max(minY, menuTop);
    }

    function getX(reference) {
        // Position menu directly at the right edge of the left bar (no gap)
        return root.x + root.implicitWidth;
    }

    ColumnLayout {
        id: column
        spacing: responsiveSizing.itemSpacing
        anchors {
            bottom: parent.bottom
            bottomMargin: responsiveSizing.bottomMargin
        }

        Cpu.Content {
            Layout.alignment: Qt.AlignCenter
            implicitHeight: responsiveSizing.meterHeight
        }

        Ram.Content {
            Layout.alignment: Qt.AlignCenter
            implicitHeight: responsiveSizing.meterHeight
        }

        Volume.Content {
            Layout.alignment: Qt.AlignCenter
            implicitHeight: responsiveSizing.meterHeight
        }

        Item {
            id: caffeineButton
            Layout.alignment: Qt.AlignCenter
            implicitWidth: Sizing.leftBarWidth
            implicitHeight: caffeineIconMetrics.height

            Rectangle {
                id: caffeineHoverBg
                anchors.centerIn: parent
                width: 0
                height: 0
                radius: Sizing.radius.medium
                color: Colors.darkSurface
                opacity: 0

                Behavior on width { NumberAnimation { duration: Animations.durations.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Animations.bezierCurves.snappy } }
                Behavior on height { NumberAnimation { duration: Animations.durations.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Animations.bezierCurves.snappy } }
                Behavior on opacity { NumberAnimation { duration: Animations.durations.fast } }
            }

            MouseArea {
                id: caffeineMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: Caffeine.toggle()

                onEntered: {
                    caffeineHoverBg.width = caffeineButton.implicitWidth - 10;
                    caffeineHoverBg.height = caffeineButton.implicitHeight + 10;
                    caffeineHoverBg.opacity = 1;
                }

                onExited: {
                    caffeineHoverBg.width = 0;
                    caffeineHoverBg.height = 0;
                    caffeineHoverBg.opacity = 0;
                }
            }

            TextMetrics {
                id: caffeineIconMetrics
                font: caffeineIcon.font
                text: caffeineIcon.name
            }

            MaterialIcon {
                id: caffeineIcon
                name: "local_cafe"
                size: root.responsiveSizing.iconSize
                color: Caffeine.active || caffeineMouseArea.containsMouse ? Colors.primary : Colors.foreground
                anchors.horizontalCenter: parent.horizontalCenter
                scale: caffeineMouseArea.containsMouse ? 1.1 : 1.0
                Behavior on scale { NumberAnimation { duration: Animations.durations.fast; easing.type: Easing.BezierSpline; easing.bezierCurve: Animations.bezierCurves.snappy } }
                Behavior on color { ColorAnimation { duration: Animations.durations.fast } }
            }
        }

        BarIcon {
            id: networkIcon
            visibility: visibilities.networkMenu
            iconSize: root.responsiveSizing.iconSize
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
            iconSize: root.responsiveSizing.iconSize
            iconName: "settings_power"
            setVisibility: visible => {
                visibilities.powerMenu = visible;
            }
        }
    }
}
