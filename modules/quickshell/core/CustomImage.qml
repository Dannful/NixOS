import QtQuick

Image {
    id: root

    Behavior on scale {
        NumberAnimation {
            duration: Animations.durations.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
        }
    }

    Behavior on rotation {
        RotationAnimation {
            duration: Animations.durations.fast
            direction: RotationAnimation.Clockwise
        }
    }
}
