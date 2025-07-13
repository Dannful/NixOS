import QtQuick
import Quickshell
import "root:/core"

Item {
    id: root

    property Size sourceSize: Size {}
    property bool asynchronous: true
    property var fillMode: Image.PreserveAspectCrop

    component Size: QtObject {
        property int width: implicitWidth
        property int height: implicitHeight
    }

    property url source

    Behavior on scale {
        NumberAnimation {
            duration: Animations.durations.fast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
        }
    }
    Behavior on rotation {
        RotationAnimation {
            duration: Animations.durations.fast
            direction: RotationAnimation.Clockwise
        }
    }

    property int currentImageIndex: 0

    onSourceChanged: {
        currentImageIndex = 1 - currentImageIndex;
    }

    Image {
        id: before
        anchors.fill: parent
        visible: source !== ""

        sourceSize.width: root.sourceSize.width
        sourceSize.height: root.sourceSize.height
        fillMode: root.fillMode

        source: root.currentImageIndex === 0 ? root.source : before.source
        opacity: root.currentImageIndex === 0 ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.durations.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
            }
        }
    }

    Image {
        id: after
        anchors.fill: parent
        visible: source !== ""

        sourceSize.width: root.sourceSize.width
        sourceSize.height: root.sourceSize.height
        fillMode: root.fillMode

        source: root.currentImageIndex === 1 ? root.source : after.source
        opacity: root.currentImageIndex === 1 ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Animations.durations.fast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Animations.bezierCurves.easeInOutQuad
            }
        }
    }
}
