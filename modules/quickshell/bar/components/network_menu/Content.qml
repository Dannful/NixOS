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

    ColumnLayout {
        anchors.centerIn: parent
        anchors.fill: parent

        Text {
            Layout.alignment: Qt.AlignCenter
            text: qsTr("<b>SSID</b>: %1").arg(Network.currentNetwork?.ssid || "-")
        }

        Text {
            Layout.alignment: Qt.AlignCenter
            text: qsTr("<b>Strength</b>: %1").arg(Network.currentNetwork?.strength || 0)
        }

        Text {
            Layout.alignment: Qt.AlignCenter
            text: qsTr("<b>Frequency</b>: %1 MHz").arg(Network.currentNetwork?.frequency || 0)
        }
    }
}
