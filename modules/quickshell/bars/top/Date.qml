import QtQuick
import Quickshell
import "root:/services"
import "root:/core"

Item {
    required property PersistentProperties visibilities
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
        animationTarget: ""
    }

    MouseArea {
        anchors.fill: text

        onClicked: {
            visibilities.calendar = !visibilities.calendar;
        }
    }
}
