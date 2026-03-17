import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "root:/core"

RowLayout {
    spacing: 0

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            property HyprlandWorkspace workspace: modelData
            visible: workspace.id >= 0
            
            Layout.leftMargin: visible ? Sizing.spacing.tiny : 0
            implicitWidth: visible ? Math.max(24, textLabel.implicitWidth + 16) : 0
            implicitHeight: visible ? 24 : 0
            radius: 12
            color: workspace.focused ? Colors.primary : (mouseArea.containsMouse ? Colors.darkSurface : "transparent")

            Behavior on implicitWidth {
                enabled: visible
                NumberAnimation {
                    duration: Animations.durations.fast
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Animations.bezierCurves.snappy
                }
            }
            
            Behavior on color { ColorAnimation { duration: Animations.durations.fast } }

            CustomText {
                id: textLabel
                anchors.centerIn: parent
                text: workspace.id !== -1 ? workspace.id : workspace.name
                color: workspace.focused ? Colors.primaryContrast : Colors.foreground
                size: Fonts.sizing.small
                font.bold: workspace.focused
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: workspace.activate()
            }
        }
    }
}
