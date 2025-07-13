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
                required property string filePath

                implicitWidth: swipeView.implicitWidth
                implicitHeight: swipeView.implicitHeight
                radius: parentRoot.radius
                color: Colors.primary

                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    source: wrapper.filePath

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
