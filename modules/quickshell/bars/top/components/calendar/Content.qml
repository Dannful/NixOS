import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "root:/core"

CustomRect {
    id: root
    color: Colors.surface
    border.color: Colors.darkSurface
    border.width: 1
    anchors.fill: parent
    radius: Sizing.radius.large
    
    // Close logic handled by Wrapper

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Sizing.margins.medium
        spacing: Sizing.spacing.medium

        // Header Section
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: Colors.darkSurface
            radius: Sizing.radius.medium

            Item {
                anchors.fill: parent
                anchors.margins: Sizing.margins.small

                MaterialIcon {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    name: "arrow_back_ios_new"
                    size: Fonts.sizing.medium
                    color: Colors.primary
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (grid.month === 0) { grid.month = 11; grid.year--; }
                            else grid.month--;
                        }
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    CustomText {
                        text: Qt.locale("pt_BR").monthName(grid.month)
                        font.bold: true
                        size: Fonts.sizing.large
                        Layout.alignment: Qt.AlignCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    CustomText {
                        text: grid.year
                        size: Fonts.sizing.small
                        opacity: 0.7
                        Layout.alignment: Qt.AlignCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MaterialIcon {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    name: "arrow_forward_ios"
                    size: Fonts.sizing.medium
                    color: Colors.primary
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (grid.month === 11) { grid.month = 0; grid.year++; }
                            else grid.month++;
                        }
                    }
                }
            }
        }

        // Days Header
        DayOfWeekRow {
            Layout.fillWidth: true
            locale: grid.locale
            delegate: CustomText {
                text: model.shortName
                horizontalAlignment: Text.AlignHCenter
                size: Fonts.sizing.small
                font.bold: true
                color: Colors.primary
                opacity: 0.8
            }
        }

        // Grid Section
        MonthGrid {
            id: grid
            Layout.fillWidth: true
            Layout.fillHeight: true
            month: new Date().getMonth()
            year: new Date().getFullYear()
            locale: Qt.locale("pt_BR")

            delegate: Rectangle {
                implicitWidth: 40
                implicitHeight: 40
                radius: 12
                color: model.today ? Colors.primary : (mouseArea.containsMouse ? Colors.darkSurface : "transparent")
                
                Behavior on color { ColorAnimation { duration: Animations.durations.fast } }

                CustomText {
                    anchors.centerIn: parent
                    text: model.day
                    size: Fonts.sizing.medium
                    font.bold: model.today
                    color: model.today ? Colors.primaryContrast : (model.month === grid.month ? Colors.foreground : Colors.darkSurface)
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }
}