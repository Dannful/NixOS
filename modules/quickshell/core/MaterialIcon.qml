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
}
