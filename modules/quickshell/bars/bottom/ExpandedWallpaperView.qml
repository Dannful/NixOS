import QtQuick
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Widgets
import Qt.labs.folderlistmodel
import "root:/core"
import "root:/services"

Item {
    id: viewRoot

    required property Item parentRoot

    property alias swipeView: swipeView

    FolderListModel {
        id: wallpapers
        folder: Qt.resolvedUrl("../../wallpapers")
        nameFilters: ["*.png", "*.jpg", "*.jpeg"]
        showDirs: false
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

                CustomImage {
                    anchors.fill: parent
                    source: Math.abs(swipeView.currentIndex - index) <= 1 ? wrapper.filePath : ""
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: parent.implicitWidth
                    sourceSize.height: parent.implicitHeight
                    asynchronous: true

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

    PageIndicator {
        id: indicator
        count: swipeView.count
        currentIndex: swipeView.currentIndex

        anchors.top: swipeView.bottom
        anchors.horizontalCenter: viewRoot.horizontalCenter
    }
}
