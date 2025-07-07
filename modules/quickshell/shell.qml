//@ pragma UseQApplication

import Quickshell
import Quickshell.Io
import QtQuick
import "root:/bar"
import "root:/core"
import "root:/bar/components"

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

                    Item {
                        implicitWidth: bar.implicitWidth
                        implicitHeight: root.implicitHeight
                    }
                }

                Bar {
                    id: bar
                    visibilities: visibilities
                    screen: root.screen
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                    }
                    implicitWidth: 60
                    implicitHeight: parent.height
                }
            }
        }
    }
}
