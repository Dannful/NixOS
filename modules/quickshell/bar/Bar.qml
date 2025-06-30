import Quickshell
import QtQuick
import QtQuick.Controls
import "root:/core"

CustomRect {
    id: root
    required property ShellScreen screen
    required property PersistentProperties visibilities
    implicitWidth: 60
    implicitHeight: screen.height
    color: "#fff"

    Power {
        visibilities: root.visibilities
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
        }
        implicitWidth: 60
        implicitHeight: 60
    }
}
