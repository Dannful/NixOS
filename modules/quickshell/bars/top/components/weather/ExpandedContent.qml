import QtQuick
import QtQuick.Layouts
import "root:/core"
import "root:/services"

CustomRect {
    id: root
    color: Colors.surface
    border.color: Colors.darkSurface
    border.width: 1
    anchors.fill: parent
    radius: Sizing.radius.large

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Sizing.margins.medium
        spacing: Sizing.spacing.small

        RowLayout {
            Layout.fillWidth: true

            MaterialIcon {
                name: Weather.currentIcon
                size: 32
                color: Colors.primary
            }

            ColumnLayout {
                spacing: 0
                CustomText {
                    text: Math.round(Weather.currentTemp) + "°C"
                    font.bold: true
                    size: Fonts.sizing.large
                }
                CustomText {
                    text: Weather.locationName
                    size: Fonts.sizing.small
                    opacity: 0.6
                }
            }

            Item { Layout.fillWidth: true }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Sizing.spacing.small

            Repeater {
                model: Weather.daily.slice(0, 5)

                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 2

                    CustomText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(new Date(modelData.date), "ddd")
                        size: Fonts.sizing.small
                        opacity: 0.6
                    }
                    MaterialIcon {
                        Layout.alignment: Qt.AlignHCenter
                        name: modelData.icon
                        size: 18
                    }
                    CustomText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Math.round(modelData.hi) + "°/" + Math.round(modelData.lo) + "°"
                        size: 10
                        opacity: 0.7
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.darkSurface
        }

        CustomText {
            text: "System"
            font.bold: true
            size: Fonts.sizing.medium
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Repeater {
                model: System.perCoreUsage

                delegate: RowLayout {
                    required property real modelData
                    required property int index
                    Layout.fillWidth: true
                    spacing: 6

                    CustomText {
                        text: "C" + index
                        size: 9
                        opacity: 0.5
                        Layout.preferredWidth: 18
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 3
                        color: Colors.darkSurface

                        Rectangle {
                            width: parent.width * modelData
                            height: parent.height
                            radius: parent.radius
                            color: modelData > 0.85 ? Colors.error : Colors.primary

                            Behavior on width { NumberAnimation { duration: Animations.durations.medium } }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Repeater {
                model: System.disks

                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        CustomText {
                            text: modelData.mount
                            size: 10
                            opacity: 0.6
                        }
                        Item { Layout.fillWidth: true }
                        CustomText {
                            text: Math.round(modelData.usedFraction * 100) + "%"
                            size: 10
                            opacity: 0.6
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 6
                        radius: 3
                        color: Colors.darkSurface

                        Rectangle {
                            width: parent.width * modelData.usedFraction
                            height: parent.height
                            radius: parent.radius
                            color: modelData.usedFraction > 0.9 ? Colors.error : Colors.secondary

                            Behavior on width { NumberAnimation { duration: Animations.durations.medium } }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
