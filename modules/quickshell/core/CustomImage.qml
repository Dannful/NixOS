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

    Behavior on source {
        ParallelAnimation {
            SequentialAnimation {
                NumberAnimation {
                    target: root
                    property: "scale"
                    from: 1
                    to: 0
                    duration: Animations.durations.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
                }
                NumberAnimation {
                    target: root
                    property: "scale"
                    from: 0
                    to: 1
                    duration: Animations.durations.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
                }
            }
            SequentialAnimation {
                NumberAnimation {
                    target: root
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: Animations.durations.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
                }
                NumberAnimation {
                    target: root
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Animations.durations.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
                }
            }
        }
    }
}
