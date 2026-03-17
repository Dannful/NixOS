import QtQuick
import "root:/core"

Text {
    id: root
    required property string name
    property real size: Fonts.sizing.medium
    color: Colors.foreground

    text: name
    font {
        family: "Material Symbols Rounded"
        pixelSize: size
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.durations.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.smoothOut
        }
    }
}
