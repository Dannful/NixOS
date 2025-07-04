pragma Singleton

import Quickshell
import QtQuick

Singleton {

    readonly property Durations durations: Durations {}
    readonly property BezierCurves bezierCurves: BezierCurves {}

    component Durations: QtObject {
        readonly property int fast: 150
        readonly property int medium: 300
        readonly property int slow: 500
    }

    component BezierCurves: QtObject {
        readonly property list<real> easeInOutQuad: [0.45, 0.03, 0.51, 0.95]
        readonly property list<real> easeInOutCubic: [0.65, 0.05, 0.36, 1]
        readonly property list<real> easeInOutSine: [0.445, 0.05, 0.55, 0.95]
        readonly property list<real> accelerate: [0.4, 0.0, 1.0, 1.0]
        readonly property list<real> decelerate: [0.0, 0.0, 0.2, 1.0]
    }
}
