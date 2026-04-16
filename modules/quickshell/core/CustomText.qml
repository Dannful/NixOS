import QtQuick
import "root:/core"

Text {
    id: root
    property real size: Fonts.sizing.medium
    property string animationTarget: "scale"
    property real animationFrom: 0
    property real animationTo: 1
    color: Colors.foreground

    font {
        family: "FiraCode Nerd Font Mono"
        pixelSize: size
    }

    Behavior on color {
        ColorAnimation {
            duration: Animations.durations.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.smoothOut
        }
    }

    Behavior on text {
        enabled: root.animationTarget !== ""
        SequentialAnimation {
            NumberAnimation {
                target: root
                property: root.animationTarget
                to: root.animationFrom
                duration: Animations.durations.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.smoothOut
            }
            NumberAnimation {
                target: root
                property: root.animationTarget
                to: root.animationTo
                duration: Animations.durations.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.smoothOut
            }
        }
    }
}
