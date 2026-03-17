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

    // Close logic handled by Wrapper

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: Sizing.margins.medium

        Item {
            id: header
            width: parent.width
            height: 40

            CustomText {
                text: "Network"
                font.bold: true
                size: Fonts.sizing.large
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                HeaderIcon {
                    iconName: "add"
                    tooltip: "Add Connection"
                    onClicked: addDialog.open()
                }

                HeaderIcon {
                    iconName: Network.wifiEnabled ? "wifi" : "wifi_off"
                    isActive: Network.wifiEnabled
                    tooltip: Network.wifiEnabled ? "Disable Wi-Fi" : "Enable Wi-Fi"
                    isBusy: Network.busy && Network.status.indexOf("Wi-Fi") >= 0
                    onClicked: Network.toggleWifi(!Network.wifiEnabled)
                }

                HeaderIcon {
                    iconName: "sync"
                    isActive: Network.scanning
                    tooltip: "Scan"
                    isBusy: Network.scanning
                    onClicked: Network.scan()
                }
            }
        }

        Item {
            id: statusBar
            anchors.top: header.bottom
            width: parent.width
            height: Network.status ? 28 : 0
            clip: true

            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

            CustomRect {
                anchors.fill: parent
                anchors.topMargin: 4
                color: Network.status.indexOf("Error") >= 0 || Network.status.indexOf("Failed") >= 0 ? Colors.error : Colors.darkSurface
                radius: Sizing.radius.small
                opacity: 0.8

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    MaterialIcon {
                        id: statusIcon
                        name: {
                            if (Network.status.indexOf("Error") >= 0 || Network.status.indexOf("Failed") >= 0) return "error";
                            if (Network.status.indexOf("...") >= 0) return "sync";
                            return "check_circle";
                        }
                        size: 14
                        color: Colors.foreground

                        RotationAnimation {
                            target: statusIcon
                            property: "rotation"
                            running: Network.status.indexOf("...") >= 0
                            from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                            onRunningChanged: if (!running) statusIcon.rotation = 0
                        }
                    }

                    CustomText {
                        Layout.fillWidth: true
                        text: Network.status
                        size: 11
                        elide: Text.ElideRight
                    }
                }
            }
        }

        ScrollView {
            id: scrollView
            anchors.top: statusBar.bottom
            anchors.topMargin: 8
            anchors.bottom: parent.bottom
            width: parent.width
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            Column {
                width: scrollView.availableWidth
                spacing: 2

                Repeater {
                    model: Network.connections

                    delegate: ConnectionItem {
                        required property var modelData
                        required property int index

                        connName: modelData.connName || ""
                        connType: modelData.connType || ""
                        connActive: modelData.connActive || false
                        connConnecting: modelData.connConnecting || false
                        connUuid: modelData.connUuid || ""
                        connDevice: modelData.connDevice || ""
                        connUnsaved: modelData.connUnsaved || false
                        connSignal: modelData.connSignal || 0
                        connSecurity: modelData.connSecurity || ""

                        onPasswordRequired: function(ssid, security) {
                            passwordDialog.ssid = ssid;
                            passwordDialog.security = security;
                            passwordDialog.open();
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 50
                    visible: Network.connections.length === 0

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        MaterialIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "wifi_off"
                            size: 20
                            opacity: 0.4
                        }

                        CustomText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No connections"
                            opacity: 0.5
                            size: Fonts.sizing.small
                        }
                    }
                }
            }
        }
    }

    // Dialogs (full overlays)
    AddConnectionDialog {
        id: addDialog
        anchors.fill: parent
        z: 100
    }

    PasswordDialog {
        id: passwordDialog
        anchors.fill: parent
        z: 101
    }

    // Reusable Components
    component HeaderIcon: CustomRect {
        id: headerIconRoot
        property string iconName
        property bool isActive: false
        property bool isBusy: false
        property string tooltip: ""
        signal clicked

        width: 32; height: 32; radius: 16
        color: isActive ? Colors.primary : "transparent"
        border.color: headerIconMouse.containsMouse ? Colors.primary : Colors.darkSurface
        border.width: 1
        scale: headerIconMouse.pressed ? 0.9 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }

        MaterialIcon {
            id: headerIconIcon
            anchors.centerIn: parent
            name: headerIconRoot.iconName
            size: 18
            color: headerIconRoot.isActive ? Colors.primaryContrast : Colors.foreground

            RotationAnimation {
                target: headerIconIcon
                property: "rotation"
                running: headerIconRoot.isBusy
                from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                onRunningChanged: if (!running) headerIconIcon.rotation = 0
            }
        }

        MouseArea {
            id: headerIconMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: headerIconRoot.clicked()
        }

        ToolTip {
            visible: headerIconMouse.containsMouse && headerIconRoot.tooltip
            text: headerIconRoot.tooltip
            delay: 500
        }
    }

    component ConnectionItem: CustomRect {
        id: connItem
        property string connName
        property string connType
        property bool connActive
        property bool connConnecting
        property string connUuid
        property string connDevice
        property bool connUnsaved
        property int connSignal
        property string connSecurity

        signal passwordRequired(string ssid, string security)

        readonly property bool isVpn: connType.indexOf("vpn") >= 0 || connType === "wireguard"
        readonly property bool isEthernet: connType.indexOf("ethernet") >= 0
        readonly property bool isWifi: connType.indexOf("wireless") >= 0
        readonly property bool isPending: Network.pendingConnection === connName
        readonly property bool needsPassword: connUnsaved && connSecurity && connSecurity !== "" && connSecurity !== "--"

        width: parent ? parent.width : 0
        height: 48
        color: connMouse.containsMouse ? Colors.darkSurface : "transparent"
        radius: Sizing.radius.small
        opacity: connConnecting || isPending ? 0.7 : 1.0

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            Item {
                width: 24; height: 24
                MaterialIcon {
                    id: connTypeIcon
                    anchors.centerIn: parent
                    name: {
                        if (connItem.isVpn) return "vpn_lock";
                        if (connItem.isEthernet) return "settings_ethernet";
                        if (connItem.connSignal > 66) return "signal_wifi_4_bar";
                        if (connItem.connSignal > 33) return "network_wifi_3_bar";
                        if (connItem.connSignal > 0) return "network_wifi_1_bar";
                        return "wifi";
                    }
                    size: 20
                    color: connItem.connActive ? Colors.primary : Colors.foreground
                    opacity: connItem.connActive ? 1.0 : 0.6

                    RotationAnimation {
                        target: connTypeIcon
                        property: "rotation"
                        running: connItem.connConnecting || connItem.isPending
                        from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                        onRunningChanged: if (!running) connTypeIcon.rotation = 0
                    }
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: 2

                CustomText {
                    text: connItem.connName
                    font.bold: connItem.connActive
                    color: connItem.connActive ? Colors.primary : Colors.foreground
                    size: Fonts.sizing.small
                    width: parent.width
                    elide: Text.ElideRight
                }

                Row {
                    spacing: 6

                    CustomText {
                        text: {
                            if (connItem.connConnecting || connItem.isPending) return "Connecting...";
                            if (connItem.isVpn) return connItem.connType === "wireguard" ? "WireGuard" : "VPN";
                            if (connItem.isEthernet) return "Ethernet";
                            if (connItem.isWifi) return "Wi-Fi";
                            return connItem.connType;
                        }
                        size: 10
                        opacity: 0.5
                    }

                    MaterialIcon {
                        visible: connItem.needsPassword
                        name: "lock"
                        size: 10
                        opacity: 0.4
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    CustomText {
                        visible: connItem.connUnsaved && !connItem.needsPassword
                        text: "Open"
                        size: 10
                        opacity: 0.4
                        font.italic: true
                    }
                }
            }

            Row {
                spacing: 8

                MaterialIcon {
                    id: deleteIcon
                    visible: connItem.connUuid && connMouse.containsMouse && !connItem.connConnecting && !connItem.isPending
                    name: "delete"
                    size: 16
                    color: connItem.deleteHovered ? Colors.error : Colors.foreground
                    opacity: connItem.deleteHovered ? 1.0 : 0.4
                }

                MaterialIcon {
                    visible: connItem.connActive && !connItem.connConnecting && !connItem.isPending
                    name: "check_circle"
                    size: 18
                    color: Colors.primary
                }

                MaterialIcon {
                    id: connSyncIcon
                    visible: connItem.connConnecting || connItem.isPending
                    name: "sync"
                    size: 18
                    color: Colors.primary

                    RotationAnimation {
                        target: connSyncIcon
                        property: "rotation"
                        running: connSyncIcon.visible
                        from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                        onRunningChanged: if (!running) connSyncIcon.rotation = 0
                    }
                }
            }
        }

        property bool deleteHovered: false

        MouseArea {
            id: connMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: !connItem.connConnecting && !connItem.isPending

            onPositionChanged: function(mouse) {
                if (deleteIcon.visible) {
                    let deletePos = deleteIcon.mapToItem(connMouse, 0, 0);
                    connItem.deleteHovered = mouse.x >= deletePos.x - 6 &&
                                             mouse.x <= deletePos.x + deleteIcon.width + 6 &&
                                             mouse.y >= deletePos.y - 6 &&
                                             mouse.y <= deletePos.y + deleteIcon.height + 6;
                } else {
                    connItem.deleteHovered = false;
                }
            }

            onExited: connItem.deleteHovered = false

            onClicked: function(mouse) {
                if (connItem.deleteHovered) {
                    Network.deleteConnection(connItem.connUuid, connItem.connName);
                } else if (connItem.connActive) {
                    Network.deactivateConnection(connItem.connUuid, connItem.connName, connItem.connDevice);
                } else if (connItem.needsPassword) {
                    connItem.passwordRequired(connItem.connName, connItem.connSecurity);
                } else {
                    Network.activateConnection(connItem.connUuid, connItem.connName);
                }
            }
        }
    }
}
