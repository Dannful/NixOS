//@ pragma UseQApplication

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtMultimedia
import "root:/core"
import "root:/bars/left"
import "root:/bars/top"
import "root:/bars/right"
import "root:/bars/bottom"
import "root:/bars"
import "root:/services"
import "root:/notifications"

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

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.keyboardFocus: (visibilities.powerMenu || visibilities.networkMenu || visibilities.calendar)
                    ? WlrKeyboardFocus.OnDemand
                    : WlrKeyboardFocus.None

                mask: Region {
                    id: mask
                    regions: notificationCenter.hasNotifications
                        ? [...regions.instances, notificationRegion]
                        : regions.instances
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
                    }
                }

                Region {
                    id: notificationRegion
                    x: notificationCenter.x
                    y: notificationCenter.y
                    width: notificationCenter.implicitWidth
                    height: notificationCenter.implicitHeight
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
                        leftMargin: Sizing.margins.small
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
                        margins: Sizing.margins.small
                    }
                }

                NotificationCenter {
                    id: notificationCenter
                    screen: root.screen
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

                property string wallpaperPath: BackgroundManager.backgrounds[backgroundPanel.screen.model] ?? Qt.resolvedUrl("./wallpapers/ai.png")
                property bool isVideo: {
                    const path = wallpaperPath.toLowerCase();
                    return path.endsWith(".mp4") || path.endsWith(".webm") || path.endsWith(".mkv") ||
                           path.endsWith(".avi") || path.endsWith(".mov");
                }
                property string wallpaperUrl: wallpaperPath.startsWith("file://") ? wallpaperPath : "file://" + wallpaperPath

                Loader {
                    width: backgroundPanel.screen.width
                    height: backgroundPanel.screen.height
                    sourceComponent: backgroundPanel.isVideo ? videoBackground : imageBackground
                }

                Component {
                    id: imageBackground
                    CustomImage {
                        width: backgroundPanel.screen.width
                        height: backgroundPanel.screen.height
                        sourceSize.width: backgroundPanel.screen.width
                        sourceSize.height: backgroundPanel.screen.height
                        source: backgroundPanel.wallpaperPath
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }
                }

                Component {
                    id: videoBackground
                    Video {
                        width: backgroundPanel.screen.width
                        height: backgroundPanel.screen.height
                        source: backgroundPanel.wallpaperUrl
                        fillMode: VideoOutput.PreserveAspectCrop
                        autoPlay: true
                        loops: MediaPlayer.Infinite
                        muted: true
                    }
                }
            }
        }
    }
}
