pragma Singleton

import Quickshell
import QtQuick

Singleton {

    readonly property Margins margins: Margins {}
    readonly property Spacing spacing: Spacing {}
    readonly property Radius radius: Radius {}
    readonly property Meter meter: Meter {}
    readonly property int leftBarWidth: 51
    readonly property int topBarHeight: 29
    readonly property int networkMenuWidth: 250

    component Meter: QtObject {
        readonly property int width: 6
        readonly property int height: 150
    }

    component Margins: QtObject {
        readonly property int tiny: 4
        readonly property int small: 8
        readonly property int medium: 16
        readonly property int large: 24
        readonly property int xlarge: 32
    }

    component Spacing: QtObject {
        readonly property int tiny: 9
        readonly property int small: 15
        readonly property int medium: 20
        readonly property int large: 25
        readonly property int xlarge: 30
    }

    component Radius: QtObject {
        readonly property int small: 5
        readonly property int medium: 10
        readonly property int large: 15
        readonly property int xlarge: 20
    }
}
