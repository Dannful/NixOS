import QtQuick
import QtQuick.Layouts
import "root:/core"
import "root:/services"
import "root:/bars/components"

CustomRect {
    id: root
    color: Colors.surface
    border.color: Colors.darkSurface
    border.width: 1
    anchors.fill: parent
    radius: Sizing.radius.large

    component Graph: ColumnLayout {
        property string label
        property color accent
        property var history
        property real rate

        Layout.fillWidth: true
        spacing: 4

        RowLayout {
            MaterialIcon {
                name: label === "Download" ? "arrow_downward" : "arrow_upward"
                size: 14
                color: accent
            }
            CustomText {
                text: label
                size: Fonts.sizing.small
                opacity: 0.7
            }
            Item { Layout.fillWidth: true }
            CustomText {
                text: NetSpeed.humanRate(rate)
                size: Fonts.sizing.small
                font.bold: true
                animationTarget: ""
            }
        }

        Sparkline {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            values: history
            lineColor: accent
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Sizing.margins.medium
        spacing: Sizing.spacing.small

        CustomText {
            text: "Network"
            font.bold: true
            size: Fonts.sizing.large
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Sizing.spacing.medium

            Graph {
                label: "Download"
                accent: Colors.primary
                history: NetSpeed.rxHistory
                rate: NetSpeed.rxRate
            }

            Graph {
                label: "Upload"
                accent: Colors.secondary
                history: NetSpeed.txHistory
                rate: NetSpeed.txRate
            }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
            Layout.fillWidth: true
            CustomText {
                text: "This session: ↓ " + NetSpeed.humanBytes(NetSpeed.sessionRxBytes) + " · ↑ " + NetSpeed.humanBytes(NetSpeed.sessionTxBytes)
                size: Fonts.sizing.small
                opacity: 0.6
            }
        }
    }
}
