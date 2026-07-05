import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "root:/core"
import "root:/services"

CustomRect {
    id: root
    color: Colors.surface
    border.color: Colors.darkSurface
    border.width: 1
    anchors.fill: parent
    radius: Sizing.radius.large

    component ActionButton: CustomRect {
        property string label
        property bool primary: false
        signal clicked

        implicitWidth: actionText.implicitWidth + 20
        implicitHeight: 28
        radius: Sizing.radius.medium
        color: primary ? Colors.primary : "transparent"
        border.color: primary ? Colors.primary : Colors.darkSurface
        border.width: 1

        CustomText {
            id: actionText
            anchors.centerIn: parent
            text: label
            size: Fonts.sizing.small
            color: primary ? Colors.primaryContrast : Colors.foreground
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Sizing.margins.medium
        spacing: Sizing.spacing.small

        RowLayout {
            Layout.fillWidth: true

            CustomText {
                text: "Displays"
                font.bold: true
                size: Fonts.sizing.large
            }

            Item { Layout.fillWidth: true }

            MaterialIcon {
                name: "sync"
                size: 16
                opacity: 0.6

                RotationAnimation {
                    running: Monitors.busy
                    target: parent
                    property: "rotation"
                    from: 0; to: 360; duration: 800; loops: Animation.Infinite
                    onRunningChanged: if (!running) parent.rotation = 0
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Monitors.refresh()
                }
            }
        }

        CustomText {
            visible: Monitors.lastError !== ""
            text: Monitors.lastError
            color: Colors.error
            size: Fonts.sizing.small
        }

        // Arrangement canvas: drag monitors to reposition them (snaps to sit
        // left-of/right-of/above/below a neighbor rather than free placement)
        Rectangle {
            id: arrangeArea
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            radius: Sizing.radius.medium
            color: Colors.darkSurface
            clip: true

            readonly property var effectiveMonitors: Monitors.monitors.map(m => Monitors.effective(m))
            readonly property real boundsMinX: effectiveMonitors.length ? Math.min(...effectiveMonitors.map(m => m.x)) : 0
            readonly property real boundsMinY: effectiveMonitors.length ? Math.min(...effectiveMonitors.map(m => m.y)) : 0
            readonly property real boundsMaxX: effectiveMonitors.length ? Math.max(...effectiveMonitors.map(m => m.x + m.width / m.scale)) : 1
            readonly property real boundsMaxY: effectiveMonitors.length ? Math.max(...effectiveMonitors.map(m => m.y + m.height / m.scale)) : 1
            readonly property real spanX: Math.max(1, boundsMaxX - boundsMinX)
            readonly property real spanY: Math.max(1, boundsMaxY - boundsMinY)
            readonly property real scaleFactor: Math.min((width - 20) / spanX, (height - 20) / spanY)

            Repeater {
                model: Monitors.monitors

                delegate: Rectangle {
                    id: monitorCard
                    required property var modelData
                    required property int index

                    readonly property var eff: Monitors.effective(modelData)
                    readonly property real logicalWidth: eff.width / eff.scale
                    readonly property real logicalHeight: eff.height / eff.scale

                    property real dragX: eff.x
                    property real dragY: eff.y

                    // Re-sync the drag position whenever staged/live data changes underneath us
                    onEffChanged: {
                        if (!dragHandler.active) {
                            dragX = eff.x;
                            dragY = eff.y;
                        }
                    }

                    width: Math.max(24, logicalWidth * arrangeArea.scaleFactor)
                    height: Math.max(18, logicalHeight * arrangeArea.scaleFactor)
                    x: 10 + (dragX - arrangeArea.boundsMinX) * arrangeArea.scaleFactor
                    y: 10 + (dragY - arrangeArea.boundsMinY) * arrangeArea.scaleFactor
                    radius: Sizing.radius.small
                    color: modelData.focused ? Colors.primary : Colors.surface
                    border.color: Monitors.isPending(modelData.name) ? Colors.warning : Colors.foreground
                    border.width: Monitors.isPending(modelData.name) ? 2 : 1

                    CustomText {
                        anchors.centerIn: parent
                        text: monitorCard.modelData.name
                        size: 9
                        color: monitorCard.modelData.focused ? Colors.primaryContrast : Colors.foreground
                        elide: Text.ElideRight
                        width: parent.width - 4
                        horizontalAlignment: Text.AlignHCenter
                    }

                    DragHandler {
                        id: dragHandler
                        target: null
                        onActiveChanged: {
                            if (!active) {
                                const snapped = Monitors.snapPosition(monitorCard.modelData, monitorCard.dragX, monitorCard.dragY);
                                monitorCard.dragX = snapped.x;
                                monitorCard.dragY = snapped.y;
                                Monitors.stagePosition(monitorCard.modelData, snapped.x, snapped.y);
                            }
                        }
                        onTranslationChanged: {
                            if (active) {
                                monitorCard.dragX = monitorCard.eff.x + translation.x / arrangeArea.scaleFactor;
                                monitorCard.dragY = monitorCard.eff.y + translation.y / arrangeArea.scaleFactor;
                            }
                        }
                    }
                }
            }
        }

        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: scrollView.availableWidth
                spacing: Sizing.spacing.small

                Repeater {
                    model: Monitors.monitors

                    delegate: CustomRect {
                        id: card
                        required property var modelData
                        readonly property var eff: Monitors.effective(modelData)

                        Layout.fillWidth: true
                        implicitHeight: cardLayout.implicitHeight + 16
                        radius: Sizing.radius.medium
                        color: Colors.darkSurface
                        border.color: Monitors.isPending(modelData.name) ? Colors.warning : (card.modelData.focused ? Colors.primary : "transparent")
                        border.width: 1

                        ColumnLayout {
                            id: cardLayout
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true

                                MaterialIcon {
                                    name: "desktop_windows"
                                    size: 16
                                    color: card.modelData.focused ? Colors.primary : Colors.foreground
                                }

                                CustomText {
                                    text: card.modelData.name
                                    font.bold: true
                                    size: Fonts.sizing.small
                                }

                                Item { Layout.fillWidth: true }

                                CustomText {
                                    text: Math.round(card.eff.scale * 100) + "%"
                                    size: 10
                                    opacity: 0.6
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                MaterialIcon {
                                    name: "chevron_left"
                                    size: 16
                                    opacity: (card.modelData.availableModes || []).length > 1 ? 1 : 0.3

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            const modes = card.modelData.availableModes || [];
                                            if (modes.length < 2) return;
                                            const cur = card.eff.width + "x" + card.eff.height + "@" + card.eff.refreshRate.toFixed(2) + "Hz";
                                            let idx = modes.indexOf(cur);
                                            if (idx < 0) idx = 0;
                                            idx = (idx - 1 + modes.length) % modes.length;
                                            Monitors.stageMode(card.modelData, modes[idx]);
                                        }
                                    }
                                }

                                CustomText {
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    text: card.eff.width + "x" + card.eff.height + " @ " + Math.round(card.eff.refreshRate) + "Hz"
                                    size: Fonts.sizing.small
                                }

                                MaterialIcon {
                                    name: "chevron_right"
                                    size: 16
                                    opacity: (card.modelData.availableModes || []).length > 1 ? 1 : 0.3

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            const modes = card.modelData.availableModes || [];
                                            if (modes.length < 2) return;
                                            const cur = card.eff.width + "x" + card.eff.height + "@" + card.eff.refreshRate.toFixed(2) + "Hz";
                                            let idx = modes.indexOf(cur);
                                            if (idx < 0) idx = 0;
                                            idx = (idx + 1) % modes.length;
                                            Monitors.stageMode(card.modelData, modes[idx]);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    height: 40
                    visible: Monitors.monitors.length === 0

                    CustomText {
                        anchors.centerIn: parent
                        text: "No monitors found"
                        opacity: 0.5
                        size: Fonts.sizing.small
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: Monitors.hasPending()
            spacing: Sizing.spacing.small

            CustomText {
                text: "Unapplied changes"
                size: Fonts.sizing.small
                color: Colors.warning
                Layout.fillWidth: true
            }

            ActionButton {
                label: "Discard"
                onClicked: Monitors.discardAll()
            }

            ActionButton {
                label: "Apply"
                primary: true
                onClicked: Monitors.applyAll()
            }
        }
    }
}
