import QtQuick

import "root:/core"

Rectangle {
    id: root
    color: "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Animations.durations.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.smoothOut
        }
    }
}
