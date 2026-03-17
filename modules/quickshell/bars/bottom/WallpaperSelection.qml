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
    border.color: Colors.darkSurface
    border.width: 1
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
                target: contentLoader.item?.swipeView ?? null
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
                duration: Animations.durations.medium
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.snappy
            }
            NumberAnimation {
                target: contentLoader.item?.swipeView ?? null
                properties: "scale, opacity"
                duration: Animations.durations.medium
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.snappy
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

        Loader {
            id: contentLoader
            anchors.fill: parent
            active: hoverArea.containsMouse || root.radius < 180

            sourceComponent: Component {
                ExpandedWallpaperView {
                    parentRoot: root
                }
            }
        }
    }
}
