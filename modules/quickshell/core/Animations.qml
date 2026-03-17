pragma Singleton

import Quickshell
import QtQuick

Singleton {

    readonly property Durations durations: Durations {}
    readonly property BezierCurves bezierCurves: BezierCurves {}

    component Durations: QtObject {
        readonly property int ultra_fast: 36
        readonly property int fast: 100
        readonly property int medium: 200
        readonly property int slow: 300
    }

    component BezierCurves: QtObject {
        readonly property list<real> easeInOutQuad: [0.45, 0.03, 0.51, 0.95]
        readonly property list<real> easeInOutCubic: [0.65, 0.05, 0.36, 1]
        readonly property list<real> easeInOutSine: [0.445, 0.05, 0.55, 0.95]
        readonly property list<real> accelerate: [0.4, 0.0, 1.0, 1.0]
        readonly property list<real> decelerate: [0.0, 0.0, 0.2, 1.0]
        readonly property list<real> snappy: [0.05, 0.9, 0.1, 1.05]
        readonly property list<real> smoothOut: [0.16, 1, 0.3, 1]
    }
}
