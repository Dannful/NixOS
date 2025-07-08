import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "root:/core"
import "root:/services"

CustomRect {
    color: Colors.surface
    anchors.fill: parent

    bottomLeftRadius: 10
    bottomRightRadius: 10
    topLeftRadius: 10
    topRightRadius: 10

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            visibilities.networkMenu = true;
        }
        onExited: {
            visibilities.networkMenu = false;
        }

        ColumnLayout {
            anchors.centerIn: parent
            anchors.fill: parent

            visible: parent.width >= Sizing.networkMenuWidth

            AnimatedText {
                Layout.alignment: Qt.AlignCenter
                text: qsTr("<b>SSID</b>: %1").arg(Network.currentNetwork?.ssid || "-")
            }

            AnimatedText {
                Layout.alignment: Qt.AlignCenter
                text: qsTr("<b>Strength</b>: %1").arg(Network.currentNetwork?.strength || 0)
            }

            AnimatedText {
                Layout.alignment: Qt.AlignCenter
                text: qsTr("<b>Frequency</b>: %1 MHz").arg(Network.currentNetwork?.frequency || 0)
            }
        }
    }

    component AnimatedText: CustomText {
        id: animatedText
        size: Fonts.sizing.small
        opacity: parent.width >= Sizing.networkMenuWidth ? 1 : 0
        animationTarget: "opacity"

        Behavior on opacity {
            SequentialAnimation {
                NumberAnimation {
                    target: animatedText
                    property: "scale"
                    from: 0
                    to: 1
                    duration: Animations.durations.ultra_fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
                }
            }
        }
    }
}
