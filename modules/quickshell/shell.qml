//@ pragma UseQApplication

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel
import "root:/core"
import "root:/bars/left"
import "root:/bars/top"
import "root:/bars/right"
import "root:/bars/bottom"
import "root:/bars"
import "root:/services"
import Quickshell.Services.Mpris

Scope {
    id: scope

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
                    property bool calendar: false
                }

                mask: Region {
                    id: mask
                    width: root.implicitWidth
                    height: root.implicitHeight
                    intersection: Intersection.Xor
                    regions: regions.instances
                }

                Image {}

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
                    leftBar: leftBar
                    topBar: topBar

                    Item {
                        implicitWidth: leftBar.implicitWidth
                        implicitHeight: root.implicitHeight
                    }

                    Item {
                        implicitWidth: root.implicitWidth
                        implicitHeight: topBar.implicitHeight
                    }

                    Music {
                        panel: panels
                    }

                    WallpaperSelection {
                        screen: root.screen
                        panel: parent
                    }
                }

                LeftBar {
                    id: leftBar
                    visibilities: visibilities
                    screen: root.screen
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                    }
                }

                TopBar {
                    id: topBar
                    visibilities: visibilities
                    screen: root.screen
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: backgroundPanel
                property var modelData
                screen: modelData
                color: "black"
                anchors {
                    left: true
                    bottom: true
                    right: true
                    top: true
                }

                WlrLayershell.layer: WlrLayer.Background

                CustomImage {
                    id: image
                    width: backgroundPanel.screen.width
                    height: backgroundPanel.screen.height
                    sourceSize.width: backgroundPanel.screen.width
                    sourceSize.height: backgroundPanel.screen.height
                    source: BackgroundManager.backgrounds[backgroundPanel.screen.model] ?? Qt.resolvedUrl("./wallpapers/ai.png")
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }
    }
}
