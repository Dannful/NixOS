import QtQuick
import "root:/core"

Text {
    required property string name
    property real size: Fonts.sizing.medium

    text: name
    font {
        family: "Material Symbols Rounded"
        pixelSize: size
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.durations.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
        }
    }
}
