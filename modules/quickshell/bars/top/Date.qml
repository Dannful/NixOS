import QtQuick
import Quickshell
import "root:/services"
import "root:/core"

Item {
    required property PersistentProperties visibilities

    // Expose hover state for menu closing logic
    property alias containsMouse: mouseArea.containsMouse

    implicitWidth: Fonts.sizing.medium / 2
    implicitHeight: Fonts.sizing.medium / 2

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    CustomText {
        id: text
        anchors.centerIn: parent
        font.family: "FiraCode Nerd Font Mono"
        font.pixelSize: Fonts.sizing.medium
        text: Qt.locale("pt_BR").toString(clock.date, "hh:mm:ss ddd, d MMM")
        color: mouseArea.containsMouse || visibilities.calendar ? Colors.primary : Colors.foreground
        animationTarget: ""
    }

    MouseArea {
        id: mouseArea
        anchors.fill: text
        hoverEnabled: true

        onClicked: {
            visibilities.calendar = !visibilities.calendar;
        }
    }
}
