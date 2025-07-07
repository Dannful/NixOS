pragma Singleton

import Quickshell
import QtQuick

Singleton {

    readonly property Margins margins: Margins {}
    readonly property Spacing spacing: Spacing {}
    readonly property int barWidth: 60

    component Margins: QtObject {
        readonly property int small: 8
        readonly property int medium: 16
        readonly property int large: 24
        readonly property int xlarge: 32
    }

    component Spacing: QtObject {
        readonly property int small: 15
        readonly property int medium: 20
        readonly property int large: 25
        readonly property int xlarge: 30
    }
}
