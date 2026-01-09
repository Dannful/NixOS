import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "root:/core"
import "root:/services"

CustomRect {
    id: root
    color: Colors.surface
    anchors.fill: parent

    bottomLeftRadius: 10
    bottomRightRadius: 10
    topLeftRadius: 10
    topRightRadius: 10
    
    property string expandedSsid: ""
    
    Binding {
        target: Network
        property: "updatesFrozen"
        value: root.expandedSsid !== ""
    }

    Timer {
        id: closeTimer
        interval: 200
        onTriggered: visibilities.networkMenu = false
    }

    HoverHandler {
        id: mouseHandler
        onHoveredChanged: {
            if (hovered) {
                closeTimer.stop()
                visibilities.networkMenu = true;
            } else {
                closeTimer.start()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Sizing.margins.medium
        spacing: Sizing.spacing.small

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        CustomText {
                            text: "Wi-Fi"
                            size: Fonts.sizing.large
                            font.bold: true
                        }
        
                        MaterialIcon {
                            name: "refresh"
                            size: Fonts.sizing.large
                            color: Colors.onsurface
                            opacity: Network.scanning ? 0.4 : 1.0
        
                            // Rotate animation while scanning
                            RotationAnimator on rotation {
                                running: Network.scanning
                                from: 0; to: 360; duration: 1000
                                loops: Animation.Infinite
                            }
                            
                            // Reset rotation when not scanning
                            onOpacityChanged: if (!Network.scanning) rotation = 0
        
                            MouseArea {
                                anchors.fill: parent
                                enabled: !Network.scanning
                                onClicked: Network.scan()
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Wi-Fi Toggle Switch
                        Rectangle {
                            width: 40
                            height: 20
                            radius: 10
                            color: Network.wifiEnabled ? Colors.primary : Colors.darkSurface
                            
                            Rectangle {
                                x: Network.wifiEnabled ? 22 : 2
                                y: 2
                                width: 16
                                height: 16
                                radius: 8
                                color: Colors.background
                                
                                Behavior on x {
                                    NumberAnimation { duration: Animations.durations.fast }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Network.toggleWifi(!Network.wifiEnabled)
                            }
                        }
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Colors.darkSurface
                        opacity: 0.5
                    }
        
                    // Content Area
                    Loader {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        sourceComponent: Network.wifiEnabled ? networkList : disabledMessage
                    }
                }
        
                    Component.onCompleted: Network.scan()
        
                    
        
                    property bool isMenuVisible: visibilities.networkMenu
        
                    onIsMenuVisibleChanged: if (isMenuVisible) Network.scan()
        
                
        
                    Component {                id: disabledMessage
                ColumnLayout {
                    Item { Layout.fillHeight: true }
                    CustomText {
                        text: "Wi-Fi is disabled"
                        Layout.alignment: Qt.AlignCenter
                        color: Colors.onsurface
                        opacity: 0.6
                    }
                    Item { Layout.fillHeight: true }
                }
            }
            
            Component {
                id: scanningMessage
                ColumnLayout {
                    Item { Layout.fillHeight: true }
                    BusyIndicator {
                        Layout.alignment: Qt.AlignCenter
                        running: true
                        palette.dark: Colors.primary 
                    }
                    CustomText {
                        text: "Scanning..."
                        Layout.alignment: Qt.AlignCenter
                        color: Colors.onsurface
                        opacity: 0.6
                    }
                    Item { Layout.fillHeight: true }
                }
            }
            
            Component {
                id: emptyMessage
                ColumnLayout {
                    Item { Layout.fillHeight: true }
                    CustomText {
                        text: "No networks found"
                        Layout.alignment: Qt.AlignCenter
                        color: Colors.onsurface
                        opacity: 0.6
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }
    Component {
        id: networkList
        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: {
                if (Network.scanning && Network.networks.length === 0) return scanningMessage;
                if (Network.networks.length === 0) return emptyMessage;
                return listViewComponent;
            }
        }
    }
    
    Component {
        id: listViewComponent
        ListView {
            clip: true
            model: Network.networks
            delegate: networkDelegate
            spacing: 5
            
            ScrollBar.vertical: ScrollBar {
                active: true
                policy: ScrollBar.AsNeeded
            }
        }
    }

    Component {
        id: networkDelegate
        ColumnLayout {
            width: ListView.view.width
            spacing: 0
            
            // Network Item Row
            CustomRect {
                Layout.fillWidth: true
                height: 40
                color: expanded ? Colors.darkSurface : "transparent"
                radius: Sizing.radius.small
                
                property bool expanded: root.expandedSsid === modelData.ssid
                
                // Animation for background color
                Behavior on color { ColorAnimation { duration: Animations.durations.fast } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 10
                    
                    CustomText {
                        text: modelData.ssid || "Hidden Network"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        font.bold: modelData.connected
                        color: modelData.connected ? Colors.primary : Colors.onsurface
                    }
                    
                    BusyIndicator {
                        visible: Network.connectingSsid === modelData.ssid
                        running: visible
                        Layout.preferredHeight: 24
                        Layout.preferredWidth: 24
                        palette.dark: Colors.primary
                    }
                    
                    CustomText {
                        text: modelData.strength + "%"
                        size: Fonts.sizing.small
                        opacity: 0.6
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    enabled: Network.connectingSsid !== modelData.ssid
                    onClicked: {
                        if (root.expandedSsid === modelData.ssid) root.expandedSsid = ""
                        else root.expandedSsid = modelData.ssid
                    }
                }
            }

            // Expanded Details
            ColumnLayout {
                visible: root.expandedSsid === modelData.ssid
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10
                Layout.bottomMargin: 10
                spacing: 10

                CustomText {
                    text: "Frequency: " + modelData.frequency + " MHz"
                    size: Fonts.sizing.small
                    opacity: 0.7
                }

                // Connect / Password
                ColumnLayout {
                    visible: !modelData.connected
                    Layout.fillWidth: true
                    spacing: 8

                    CustomRect {
                        Layout.fillWidth: true
                        height: 30
                        color: Colors.background
                        radius: Sizing.radius.small
                        
                        TextField {
                            id: passwordInput
                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            focus: true
                            
                            text: ""
                            color: Colors.onsurface
                            font.family: "FiraCode Nerd Font Mono"
                            font.pixelSize: Fonts.sizing.medium
                            
                            placeholderText: "Password"
                            
                            background: null
                            
                            onVisibleChanged: if (visible) forceActiveFocus()
                            Component.onCompleted: if (visible) forceActiveFocus()
                        }
                    }
                    
                    CustomRect {
                        Layout.fillWidth: true
                        height: 30
                        color: Colors.primary
                        radius: Sizing.radius.small
                        
                        CustomText {
                            anchors.centerIn: parent
                            text: "Connect"
                            color: Colors.background
                            font.bold: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Network.connect(modelData.ssid, passwordInput.text)
                                root.expandedSsid = ""
                            }
                        }
                    }
                }
                
                // Connected Actions
                RowLayout {
                    visible: modelData.connected
                    Layout.fillWidth: true
                    
                    CustomRect {
                        Layout.fillWidth: true
                        height: 30
                        color: "#ef5350" // Red color for disconnect
                        radius: Sizing.radius.small
                        
                        CustomText {
                            anchors.centerIn: parent
                            text: "Disconnect"
                            color: Colors.background
                            font.bold: true
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Network.disconnect(modelData.ssid)
                                root.expandedSsid = ""
                            }
                        }
                    }
                }
            }
        }
    }
}