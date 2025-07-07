import QtQuick
import Quickshell
import Quickshell.Widgets

MouseArea {
    id: root
    required property var modelData
    property real iconSize: 30

    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: {
        if (menu.menu) {
            menu.open();
        }
    }

    QsMenuAnchor {
        id: menu
        menu: root.modelData.menu
        anchor.item: icon
        anchor.rect.x: icon.implicitWidth
    }

    IconImage {
        id: icon
        source: parent.modelData.icon
        asynchronous: true
        implicitSize: parent.iconSize
    }
}
