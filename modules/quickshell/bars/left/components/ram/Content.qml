import QtQuick
import "root:/services"
import "root:/bars/components"

Meter {
    progress: System.memoryUsage
    iconName: "memory_alt"
}
