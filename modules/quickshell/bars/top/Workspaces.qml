import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "root:/core"

RowLayout {
    spacing: Sizing.spacing.tiny

    Repeater {
        model: Hyprland.workspaces

        delegate: CustomText {
            property HyprlandWorkspace workspace: modelData
            text: workspace.id !== -1 ? workspace.id : workspace.name
            color: (workspace.focused || mouseArea.containsMouse) && Colors.primary || mouseArea.containsMouse && Colors.secondary || Colors.foreground

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    workspace.activate();
                }
            }
        }
    }
}
