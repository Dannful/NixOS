import QtQuick
import QtQuick.Controls
import "root:/services"
import "root:/bars/components"
import "root:/core"

Item {
    id: root
    implicitWidth: Sizing.leftBarWidth
    implicitHeight: Sizing.meter.height

    HoverHandler {
        id: hoverHandler
    }

    ToolTip {
        parent: root
        visible: hoverHandler.hovered
        delay: 400
        x: hoverHandler.point.position.x + 12
        y: hoverHandler.point.position.y - implicitHeight / 2
        text: {
            const totalGb = System._memTotal / 1024 / 1024;
            if (!totalGb) return `${Math.round(System.memoryUsage * 100)}%`;
            const usedGb = totalGb * System.memoryUsage;
            return `${usedGb.toFixed(1)} / ${totalGb.toFixed(1)} GB (${Math.round(System.memoryUsage * 100)}%)`;
        }
    }

    Meter {
        id: meter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        progress: System.memoryUsage
        iconName: "memory_alt"
    }
}
