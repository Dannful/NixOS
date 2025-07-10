import QtQuick
import QtQuick.Controls.Material
import Quickshell
import Quickshell.Widgets
import Qt.labs.folderlistmodel
import "root:/core"
import "root:/services"

CustomRect {
    id: root
    required property ShellScreen screen
    required property Item panel
    color: Colors.background
    clip: true

    anchors {
        verticalCenter: panel.bottom
        horizontalCenter: panel.horizontalCenter
    }

    states: [
        State {
            name: "retracted"
            when: !hoverArea.containsMouse
            PropertyChanges {
                target: root
                radius: 180
                implicitWidth: 60
                implicitHeight: 60
            }
            PropertyChanges {
                target: swipeView
                scale: 0
                opacity: 0
            }
        },
        State {
            name: "expanded"
            when: hoverArea.containsMouse
            PropertyChanges {
                target: root
                radius: 30
                implicitWidth: 330
                implicitHeight: 480
            }
            PropertyChanges {
                target: swipeView
                scale: 1
                opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            from: "retracted"
            to: "expanded"
            reversible: true
            NumberAnimation {
                target: root
                properties: "implicitWidth, implicitHeight, radius"
                duration: Animations.durations.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
            }
            NumberAnimation {
                target: swipeView
                properties: "scale, opacity"
                duration: Animations.durations.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
            }
        }
    ]

    MouseArea {
        id: hoverArea
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.verticalCenter
        }
        hoverEnabled: true

        MaterialIcon {
            name: "wallpaper"
            anchors.centerIn: parent
            size: Fonts.sizing.large
        }

        FolderListModel {
            id: wallpapers
            folder: Qt.resolvedUrl("../../../wallpapers")
            nameFilters: ["*.png", "*.jpg", "*.jpeg"]
            showDirs: false
        }

        SwipeView {
            id: swipeView
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            implicitHeight: root.implicitHeight * 0.39
            implicitWidth: root.implicitWidth * 0.9
            visible: root.implicitWidth > 60

            Repeater {
                model: wallpapers
                delegate: ClippingRectangle {
                    id: wrapper
                    required property string filePath

                    implicitWidth: swipeView.implicitWidth
                    implicitHeight: swipeView.implicitHeight
                    radius: root.radius
                    color: Colors.primary

                    Image {
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        source: wrapper.filePath

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                BackgroundManager.setWallpaper(root.screen.model, wrapper.filePath);
                            }
                        }
                    }
                }
            }
        }

        PageIndicator {
            id: indicator
            visible: root.implicitWidth > 60

            count: swipeView.count
            currentIndex: swipeView.currentIndex

            anchors.top: swipeView.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
