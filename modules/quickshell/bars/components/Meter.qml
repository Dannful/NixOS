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
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                implicitHeight: parent.implicitHeight * root.progress
                color: Colors.primary
                bottomLeftRadius: parent.radius
                bottomRightRadius: parent.radius
                topLeftRadius: root.progress >= 0.96 ? parent.radius : 0
                topRightRadius: root.progress >= 0.96 ? parent.radius : 0

                Behavior on implicitHeight {
                    NumberAnimation {
                        duration: Animations.durations.slow
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
                    }
                }

                Behavior on topLeftRadius {
                    NumberAnimation {
                        duration: Animations.durations.slow
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
                    }
                }

                Behavior on topRightRadius {
                    NumberAnimation {
                        duration: Animations.durations.slow
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!mutable)
                        return;
                    const progress = (meter.height - mouseY) / meter.height;
                    root.changed(progress);
                }

                onWheel: wheel => {
                    if (!mutable)
                        return;
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
                id: iconArea
                anchors.fill: icon
                onClicked: root.iconClicked()
            }
        }
    }
}
