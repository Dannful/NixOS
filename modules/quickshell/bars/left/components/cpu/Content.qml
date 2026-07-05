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
            const cores = System.perCoreUsage;
            if (!cores || cores.length === 0) return `${Math.round(System.cpuUsage * 100)}%`;
            const lines = cores.map((u, i) => `Core ${i}: ${Math.round(u * 100)}%`);
            return `${Math.round(System.cpuUsage * 100)}% overall\n${lines.join("\n")}`;
        }
    }

    Meter {
        id: meter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height
        progress: System.cpuUsage
        iconName: "memory"
    }
}
