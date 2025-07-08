import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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

    RowLayout {
        id: header

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        MaterialIcon {
            name: "arrow_left"
            size: Fonts.sizing.large

            MouseArea {
                anchors.fill: parent
                Layout.alignment: Qt.AlignLeft
                onClicked: {
                    grid.month = (grid.month - 1 + 12) % 12;
                    if (grid.month === 11) {
                        grid.year -= 1;
                    }
                }
            }
        }

        CustomText {
            id: title
            text: qsTr("%1/%2").arg(Qt.locale("pt_BR").monthName(grid.month)).arg(grid.year)
            Layout.alignment: Qt.AlignCenter
            animationTarget: "scale"
        }

        MaterialIcon {
            Layout.alignment: Qt.AlignRight
            name: "arrow_right"
            size: Fonts.sizing.large

            MouseArea {
                anchors.fill: parent
                Layout.alignment: Qt.AlignLeft
                onClicked: {
                    grid.month = (grid.month + 1) % 12;
                    if (grid.month === 0) {
                        grid.year += 1;
                    }
                }
            }
        }
    }

    GridLayout {
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            leftMargin: Sizing.margins.small
            rightMargin: Sizing.margins.small
            bottomMargin: Sizing.margins.small
        }
        columns: 2

        DayOfWeekRow {
            locale: grid.locale

            Layout.column: 1
            Layout.fillWidth: true
        }

        WeekNumberColumn {
            month: grid.month
            year: grid.year
            locale: grid.locale

            Layout.fillHeight: true
        }

        MonthGrid {
            id: grid
            month: new Date().getMonth()
            year: new Date().getFullYear()
            locale: Qt.locale("pt_BR")

            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
