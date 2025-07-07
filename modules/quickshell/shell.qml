//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import QtQuick
import "root:/core"
import "root:/bars/left"
import "root:/bars/top"
import "root:/bars"

Scope {
    Variants {
        model: Quickshell.screens
        delegate: Component {
            CustomPanel {
                id: root
                property var modelData
                screen: modelData
                implicitWidth: screen.width
                implicitHeight: screen.height

                PersistentProperties {
                    id: visibilities

                    property bool powerMenu: false
                    property bool networkMenu: false
                }

                mask: Region {
                    id: mask
                    width: root.implicitWidth
                    height: root.implicitHeight
                    intersection: Intersection.Xor
                    regions: regions.instances
                }

                Variants {
                    id: regions
                    model: panels.children
                    delegate: Region {
                        property var modelData
                        x: modelData.x
                        y: modelData.y
                        width: modelData.implicitWidth
                        height: modelData.implicitHeight
                        intersection: Intersection.Subtract
                    }
                }

                Panels {
                    id: panels
                    screen: root.screen
                    visibilities: visibilities
                    bar: bar

                    Item {
                        implicitWidth: bar.implicitWidth
                        implicitHeight: root.implicitHeight
                    }
                }

                LeftBar {
                    id: bar
                    visibilities: visibilities
                    screen: root.screen
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                    }
                }

                TopBar {
                    id: topBar
                    screen: root.screen
                    anchors {
                        top: parent.top
                        left: bar.right
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
