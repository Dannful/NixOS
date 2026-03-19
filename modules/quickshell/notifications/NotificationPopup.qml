import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.Notifications

import "root:/core"

Item {
    id: root
    required property Notification notification

    implicitWidth: 380
    implicitHeight: container.height


    // Focus the app window using Hyprland native API
    function activateNotification() {
        if (notification.actions.length > 0) {
            notification.actions[0].invoke();
        }

        const appName = (notification.appName || "").toLowerCase();
        const desktopEntry = (notification.desktopEntry || "").toLowerCase();
        const summary = (notification.summary || "").toLowerCase();

        for (let i = 0; i < Hyprland.toplevels.length; i++) {
            const toplevel = Hyprland.toplevels[i];
            const title = (toplevel.title || "").toLowerCase();
            const address = toplevel.address;

            if (title.includes(appName) || title.includes(desktopEntry) ||
                (summary && title.includes(summary)) ||
                appName.includes(title.split(" ")[0])) {
                Hyprland.dispatch("focuswindow address:" + address);
                return;
            }
        }

        if (desktopEntry) {
            Hyprland.dispatch("focuswindow class:" + desktopEntry);
        } else if (appName) {
            Hyprland.dispatch("focuswindow class:" + appName);
        }
    }

    // Urgency-based accent color
    readonly property color accentColor: {
        switch (notification.urgency) {
            case NotificationUrgency.Critical: return Colors.error;
            case NotificationUrgency.Low: return Colors.darkSurface;
            default: return Colors.primary;
        }
    }

    // Fixed 8 second timeout
    readonly property real notificationTimeout: 8000

    // Hover state
    property bool isHovered: false

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: root.isHovered = hovered
    }

    // Track progress for expiration (0 to 1)
    property real progress: 0

    NumberAnimation {
        id: progressAnimation
        target: root
        property: "progress"
        from: root.progress
        to: 1
        duration: root.notificationTimeout * (1 - root.progress)
        running: notification.urgency !== NotificationUrgency.Critical && !root.isHovered && container.state === "visible"

        onFinished: {
            if (root.progress >= 1) {
                container.state = "expired";
            }
        }
    }

    Item {
        id: container
        width: parent.width
        height: contentHeight
        clip: true

        property real contentHeight: contentRow.implicitHeight + Sizing.margins.medium * 2

        state: "entering"

        states: [
            State {
                name: "entering"
                PropertyChanges {
                    target: container
                    x: root.implicitWidth + 20
                    opacity: 0
                    height: container.contentHeight
                }
            },
            State {
                name: "visible"
                PropertyChanges {
                    target: container
                    x: 0
                    opacity: 1
                    height: container.contentHeight
                }
            },
            State {
                name: "expired"
                PropertyChanges {
                    target: container
                    x: root.implicitWidth + 20
                    opacity: 0
                    height: 0
                }
            }
        ]

        transitions: [
            Transition {
                from: "entering"
                to: "visible"
                ParallelAnimation {
                    NumberAnimation {
                        target: container
                        property: "x"
                        duration: Animations.durations.medium
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Animations.bezierCurves.smoothOut
                    }
                    NumberAnimation {
                        target: container
                        property: "opacity"
                        duration: Animations.durations.medium
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Animations.bezierCurves.smoothOut
                    }
                }
            },
            Transition {
                from: "visible"
                to: "expired"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            target: container
                            property: "x"
                            duration: Animations.durations.medium
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
                        }
                        NumberAnimation {
                            target: container
                            property: "opacity"
                            duration: Animations.durations.medium
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
                        }
                    }
                    NumberAnimation {
                        target: container
                        property: "height"
                        duration: Animations.durations.fast
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Animations.bezierCurves.easeInOutCubic
                    }
                }
            }
        ]

        Component.onCompleted: state = "visible"

        // Background - clickable
        Rectangle {
            id: background
            anchors.fill: parent
            color: clickArea.containsMouse ? Colors.surface : Colors.base
            radius: Sizing.radius.medium
            border.width: 2
            border.color: root.accentColor

            Behavior on color {
                ColorAnimation { duration: Animations.durations.fast }
            }
        }

        // Main click area
        MouseArea {
            id: clickArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.activateNotification()
        }

        RowLayout {
            id: contentRow
            anchors {
                fill: parent
                margins: Sizing.margins.medium
            }
            spacing: Sizing.margins.medium

            // App icon (rounded) - only show if successfully loaded
            ClippingRectangle {
                id: iconWrapper
                Layout.preferredWidth: contentColumn.implicitHeight
                Layout.fillHeight: true
                visible: appIcon.status === Image.Ready
                radius: Sizing.radius.medium

                Image {
                    id: appIcon
                    anchors.fill: parent
                    source: notification.image || notification.appIcon || ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                }
            }

            ColumnLayout {
                id: contentColumn
                Layout.fillWidth: true
                spacing: Sizing.margins.tiny

                // Header: app name + close button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Sizing.margins.small

                    Text {
                        text: notification.appName || "Notification"
                        color: Colors.darkSurface
                        font.pixelSize: Fonts.sizing.small
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    // Close button
                    Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: Sizing.radius.small
                        color: closeMouseArea.containsMouse ? Colors.darkSurface : "transparent"

                        Behavior on color {
                            ColorAnimation { duration: Animations.durations.fast }
                        }

                        MaterialIcon {
                            anchors.centerIn: parent
                            name: "close"
                            size: Fonts.sizing.small
                            color: closeMouseArea.containsMouse ? Colors.foreground : Colors.darkSurface

                            Behavior on color {
                                ColorAnimation { duration: Animations.durations.fast }
                            }
                        }

                        MouseArea {
                            id: closeMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: container.state = "expired"
                        }
                    }
                }

                // Summary (title)
                Text {
                    text: notification.summary || ""
                    visible: notification.summary !== ""
                    color: Colors.foreground
                    font.pixelSize: Fonts.sizing.medium
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                // Body
                Text {
                    text: notification.body || ""
                    visible: notification.body !== ""
                    color: Colors.foreground
                    font.pixelSize: Fonts.sizing.small
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    opacity: 0.85
                    textFormat: Text.StyledText
                }

                // Progress bar for auto-expire
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 3
                    Layout.topMargin: Sizing.margins.tiny
                    radius: 1.5
                    color: Colors.darkSurface
                    visible: notification.urgency !== NotificationUrgency.Critical

                    Rectangle {
                        height: parent.height
                        radius: 1.5
                        color: root.accentColor
                        width: parent.width * (1 - root.progress)
                    }
                }
            }
        }
    }
}
