pragma Singleton

import Quickshell
import QtQuick

Singleton {

    readonly property Margins margins: Margins {}
    readonly property int barWidth: 60

    component Margins: QtObject {
        readonly property int small: 8
        readonly property int medium: 16
        readonly property int large: 24
        readonly property int xlarge: 32
    }
}
