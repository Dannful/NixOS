import QtQuick
import QtQuick.Layouts
import Quickshell
import "root:/core"
import "root:/services"
import "root:/bars/components"

Item {
    id: root
    required property PersistentProperties visibilities

    property alias containsMouse: hoverHandler.hovered

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    HoverHandler {
        id: hoverHandler
    }

    TapHandler {
        onTapped: root.visibilities.netSpeed = !root.visibilities.netSpeed
    }

    RowLayout {
        id: layout
        anchors.verticalCenter: parent.verticalCenter
        spacing: Sizing.spacing.minimal

        Sparkline {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 20
            values: NetSpeed.rxHistory
            lineColor: root.containsMouse || root.visibilities.netSpeed ? Colors.primary : Colors.foreground
        }

        ColumnLayout {
            spacing: 0

            RowLayout {
                spacing: 2
                MaterialIcon { name: "arrow_downward"; size: 10; color: Colors.foreground }
                CustomText { text: NetSpeed.humanRate(NetSpeed.rxRate); size: 10; animationTarget: "" }
            }

            RowLayout {
                spacing: 2
                MaterialIcon { name: "arrow_upward"; size: 10; color: Colors.foreground }
                CustomText { text: NetSpeed.humanRate(NetSpeed.txRate); size: 10; animationTarget: "" }
            }
        }
    }
}
