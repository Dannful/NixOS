import QtQuick
import QtQuick.Controls
import "root:/services"
import "root:/bars/components"
import "root:/core"

Item {
    id: root
    visible: Gpu.available
    implicitWidth: visible ? Sizing.leftBarWidth : 0
    implicitHeight: visible ? Sizing.meter.height : 0

    HoverHandler {
        id: hoverHandler
    }

    ToolTip {
        parent: root
        visible: hoverHandler.hovered
        delay: 400
        x: hoverHandler.point.position.x + 12
        y: hoverHandler.point.position.y - implicitHeight / 2
        text: `${Math.round(Gpu.temperature)}°C · ${Math.round(Gpu.vramUsedMb)}/${Math.round(Gpu.vramTotalMb)} MB VRAM`
    }

    Meter {
        id: meter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        progress: Gpu.usage
        iconName: "videogame_asset"
    }
}
