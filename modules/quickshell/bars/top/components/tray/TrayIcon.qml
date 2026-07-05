import QtQuick
import Quickshell
import Quickshell.Widgets
import "root:/core"

MouseArea {
    id: root
    required property var modelData
    property real iconSize: Fonts.sizing.medium

    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight
    width: implicitWidth
    height: implicitHeight

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    onClicked: mouse => {
        if (mouse.button === Qt.RightButton) {
            if (menu.menu) {
                menu.open();
            }
        } else if (mouse.button === Qt.MiddleButton) {
            root.modelData.secondaryActivate();
        } else {
            root.modelData.activate();
        }
    }

    QsMenuAnchor {
        id: menu
        menu: root.modelData.menu
        anchor.item: icon
        anchor.rect.y: icon.implicitHeight
    }

    IconImage {
        id: icon
        source: parent.modelData.icon
        asynchronous: true
        implicitSize: parent.iconSize
    }
}
