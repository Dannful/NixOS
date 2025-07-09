import QtQuick
import "root:/services"
import "root:/bars/components"

Meter {
    progress: System.cpuUsage
    iconName: "memory"
}
