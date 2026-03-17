import QtQuick
import QtQuick.Layouts
import Quickshell
import "root:/core"
import "root:/services"

CustomRect {
    id: dialog
    visible: false
    color: Colors.base
    radius: Sizing.radius.large
    border.color: Colors.darkSurface
    border.width: 1

    property string ssid: ""
    property string security: ""

    function open() {
        passwordField.text = "";
        visible = true;
        passwordField.forceActiveFocus();
    }

    function close() {
        visible = false;
        ssid = "";
        security = "";
        passwordField.text = "";
    }

    function connect() {
        if (passwordField.text.length >= 8) {
            Network.connectWifiWithPassword(dialog.ssid, passwordField.text);
            close();
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
    }

    Item {
        anchors.fill: parent
        anchors.margins: Sizing.margins.medium

        // Header
        Item {
            id: header
            width: parent.width
            height: 44

            CustomText {
                text: "Enter Password"
                font.bold: true
                size: Fonts.sizing.large
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            MaterialIcon {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                name: "close"
                size: 20
                color: closeMouse.containsMouse ? Colors.primary : Colors.foreground

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    anchors.margins: -8
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: dialog.close()
                }
            }
        }

        Column {
            anchors.top: header.bottom
            anchors.topMargin: Sizing.spacing.medium
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 20

            // Network info
            CustomRect {
                width: parent.width
                height: 56
                color: Colors.darkSurface
                radius: Sizing.radius.small

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    MaterialIcon {
                        name: "wifi"
                        size: 24
                        color: Colors.primary
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 2

                        CustomText {
                            text: dialog.ssid
                            font.bold: true
                            size: Fonts.sizing.small
                        }

                        CustomText {
                            text: dialog.security.toUpperCase()
                            size: 10
                            opacity: 0.5
                        }
                    }

                    MaterialIcon {
                        name: "lock"
                        size: 18
                        opacity: 0.5
                    }
                }
            }

            // Password field
            Column {
                width: parent.width
                spacing: 8

                CustomText {
                    text: "Password"
                    size: 11
                    opacity: 0.7
                }

                CustomRect {
                    width: parent.width
                    height: 44
                    color: Colors.darkSurface
                    radius: Sizing.radius.small
                    border.color: passwordField.activeFocus ? Colors.primary : "transparent"
                    border.width: 2

                    TextInput {
                        id: passwordField
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 44
                        verticalAlignment: TextInput.AlignVCenter
                        color: Colors.foreground
                        font.pixelSize: Fonts.sizing.small
                        font.family: "FiraCode Nerd Font Mono"
                        echoMode: showPassword.checked ? TextInput.Normal : TextInput.Password
                        clip: true
                        selectByMouse: true

                        Keys.onEscapePressed: dialog.close()
                        Keys.onReturnPressed: dialog.connect()

                        Text {
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Enter Wi-Fi password"
                            color: Colors.foreground
                            opacity: 0.3
                            font: parent.font
                            verticalAlignment: Text.AlignVCenter
                            visible: !parent.text
                        }
                    }

                    MaterialIcon {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        name: showPassword.checked ? "visibility" : "visibility_off"
                        size: 18
                        opacity: showPassword.containsMouse ? 0.8 : 0.4
                        color: Colors.foreground

                        MouseArea {
                            id: showPassword
                            property bool checked: false
                            anchors.fill: parent
                            anchors.margins: -8
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: checked = !checked
                        }
                    }
                }

                CustomText {
                    text: passwordField.text.length > 0 && passwordField.text.length < 8
                        ? "Password must be at least 8 characters"
                        : ""
                    size: 10
                    color: Colors.warning
                    opacity: 0.8
                }
            }
        }

        // Footer
        Row {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            spacing: 12

            CustomRect {
                width: 90
                height: 38
                radius: Sizing.radius.small
                color: cancelMouse.containsMouse ? Colors.darkSurface : "transparent"
                border.color: Colors.darkSurface
                border.width: 1

                CustomText {
                    anchors.centerIn: parent
                    text: "Cancel"
                    size: Fonts.sizing.small
                }

                MouseArea {
                    id: cancelMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: dialog.close()
                }
            }

            CustomRect {
                width: 90
                height: 38
                radius: Sizing.radius.small
                color: {
                    if (passwordField.text.length < 8) return Colors.darkSurface;
                    return connectMouse.containsMouse ? Qt.lighter(Colors.primary, 1.1) : Colors.primary;
                }
                opacity: passwordField.text.length < 8 ? 0.5 : 1.0

                CustomText {
                    anchors.centerIn: parent
                    text: "Connect"
                    size: Fonts.sizing.small
                    font.bold: true
                    color: passwordField.text.length < 8 ? Colors.foreground : Colors.primaryContrast
                }

                MouseArea {
                    id: connectMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: passwordField.text.length >= 8 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: dialog.connect()
                }
            }
        }
    }
}
