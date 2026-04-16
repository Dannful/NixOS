import QtQuick
import QtQuick.Layouts
import "root:/core"

Item {
    id: root
    required property real progress
    required property string iconName
    property real iconSize: Fonts.sizing.large
    property bool mutable: false

    signal changed(real progress)
    signal iconClicked

    implicitWidth: Sizing.meter.width

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            id: meter
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            implicitHeight: parent.height - iconMetrics.height

            color: Colors.darkSurface
            radius: Sizing.radius.small

            Rectangle {
                id: fill
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                implicitHeight: parent.implicitHeight * root.progress
                radius: parent.radius

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Colors.secondary }
                    GradientStop { position: 1.0; color: Colors.primary }
                }

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: Animations.durations.medium
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Animations.bezierCurves.snappy
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!mutable) return;
                    const progress = (meter.height - mouseY) / meter.height;
                    root.changed(progress);
                }
                onWheel: wheel => {
                    if (!mutable) return;
                    const delta = wheel.angleDelta.y / 120;
                    let progress = root.progress + delta * 0.1;
                    progress = Math.max(0, Math.min(1, progress));
                    root.changed(progress);
                }
            }
        }

        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.fillHeight: true

            MaterialIcon {
                id: icon
                name: iconName
                size: root.iconSize
                anchors.centerIn: parent
            }

            TextMetrics {
                id: iconMetrics
                font: icon.font
                text: icon.text
            }

            MouseArea {
                anchors.fill: icon
                onClicked: root.iconClicked()
            }
        }
    }
}
