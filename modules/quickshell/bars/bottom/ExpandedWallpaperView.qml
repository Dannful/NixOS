import QtQuick
import QtQuick.Controls.Material
import QtMultimedia
import Quickshell
import Quickshell.Widgets
import Qt.labs.folderlistmodel
import "root:/core"
import "root:/services"

Item {
    id: viewRoot

    required property Item parentRoot

    property alias swipeView: swipeView
    property bool contentReady: false

    Timer {
        interval: 300
        running: true
        onTriggered: viewRoot.contentReady = true
    }

    FolderListModel {
        id: wallpapers
        folder: Qt.resolvedUrl("../../wallpapers")
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.mp4", "*.webm", "*.mkv", "*.avi", "*.mov"]
        showDirs: false
    }

    function isVideo(filePath) {
        const ext = filePath.toLowerCase();
        return ext.endsWith(".mp4") || ext.endsWith(".webm") || ext.endsWith(".mkv") ||
               ext.endsWith(".avi") || ext.endsWith(".mov");
    }

    SwipeView {
        id: swipeView
        opacity: 0
        scale: 0
        anchors {
            horizontalCenter: viewRoot.horizontalCenter
            verticalCenter: viewRoot.verticalCenter
        }
        implicitHeight: parentRoot.implicitHeight * 0.39
        implicitWidth: parentRoot.implicitWidth * 0.9

        Repeater {
            model: wallpapers
            delegate: ClippingRectangle {
                id: wrapper
                required property int index
                required property string filePath

                implicitWidth: swipeView.implicitWidth
                implicitHeight: swipeView.implicitHeight
                radius: parentRoot.radius

                readonly property string fileUrl: filePath.startsWith("file://") ? filePath : "file://" + filePath
                readonly property bool isVideoFile: viewRoot.isVideo(filePath)
                readonly property bool shouldLoad: Math.abs(swipeView.currentIndex - index) <= 1

                Rectangle {
                    id: placeholder
                    anchors.fill: parent
                    color: Colors.darkSurface
                    opacity: contentLoader.item ? 0 : 1
                    clip: true

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Animations.durations.medium
                            easing.type: Easing.InOutQuad
                        }
                    }

                    Rectangle {
                        id: shimmer
                        width: parent.width
                        height: parent.height
                        x: -parent.width

                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 0.4; color: "transparent" }
                            GradientStop { position: 0.5; color: Qt.rgba(1, 1, 1, 0.1) }
                            GradientStop { position: 0.6; color: "transparent" }
                            GradientStop { position: 1.0; color: "transparent" }
                        }

                        SequentialAnimation on x {
                            running: wrapper.shouldLoad && !contentLoader.item
                            loops: Animation.Infinite
                            PauseAnimation { duration: 500 }
                            NumberAnimation {
                                from: -placeholder.width
                                to: placeholder.width
                                duration: 1500
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    opacity: item ? 1 : 0
                    active: wrapper.shouldLoad && viewRoot.contentReady
                    sourceComponent: wrapper.isVideoFile ? videoComponent : imageComponent

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Animations.durations.medium
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                Component {
                    id: imageComponent
                    CustomImage {
                        width: wrapper.implicitWidth
                        height: wrapper.implicitHeight
                        source: wrapper.filePath
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: wrapper.implicitWidth
                        sourceSize.height: wrapper.implicitHeight
                        asynchronous: true

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                BackgroundManager.setWallpaper(parentRoot.screen.model, wrapper.filePath);
                            }
                        }
                    }
                }

                Component {
                    id: videoComponent
                    Video {
                        width: wrapper.implicitWidth
                        height: wrapper.implicitHeight
                        source: wrapper.fileUrl
                        fillMode: VideoOutput.PreserveAspectCrop
                        autoPlay: true
                        loops: MediaPlayer.Infinite
                        muted: true

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                BackgroundManager.setWallpaper(parentRoot.screen.model, wrapper.filePath);
                            }
                        }
                    }
                }
            }
        }
    }

    PageIndicator {
        id: indicator
        count: swipeView.count
        currentIndex: swipeView.currentIndex

        anchors.top: swipeView.bottom
        anchors.horizontalCenter: viewRoot.horizontalCenter
    }
}
