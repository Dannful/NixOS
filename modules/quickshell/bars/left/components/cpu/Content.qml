import QtQuick
import "root:/services"
import "root:/bars/left/components"

Meter {
    progress: System.cpuUsage
    iconName: "memory"
}
