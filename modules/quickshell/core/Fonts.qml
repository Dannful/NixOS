pragma Singleton

import Quickshell
import QtQuick

Singleton {

    readonly property string materialIcons: "Material Symbols Rounded"

    readonly property Sizing sizing: Sizing {}

    component Sizing: QtObject {
        readonly property int small: 12
        readonly property int medium: 16
        readonly property int large: 24
        readonly property int xlarge: 36
    }
}
