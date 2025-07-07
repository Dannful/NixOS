import QtQuick
import "root:/services"
import "root:/bars/left/components"

Meter {
    progress: System.memoryUsage
    iconName: "memory_alt"
}
