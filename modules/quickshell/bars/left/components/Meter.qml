import QtQuick
import "root:/core"

Item {
    id: root
    required property real progress
    required property string iconName
    required property real barHeight
    property bool mutable: false

    signal changed(real progress)
    signal iconClicked

    implicitHeight: barHeight + iconMetrics.height

    MouseArea {
        anchors.fill: meter
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

    Rectangle {
        id: meter

        color: Colors.darkSurface
        radius: Sizing.radius.small
        implicitWidth: parent.implicitWidth
        implicitHeight: parent.barHeight

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

    MaterialIcon {
        id: icon
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: meter.bottom
        }
        name: iconName
        size: Fonts.sizing.large
    }
}
