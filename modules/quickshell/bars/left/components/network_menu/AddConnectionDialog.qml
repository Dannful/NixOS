import QtQuick
import QtQuick.Controls
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

    property int currentPage: 0
    property string connectionType: ""

    // Connection data
    property string profileName: ""
    property string ssid: ""
    property string security: "wpa-psk"
    property string password: ""
    property bool hidden: false
    property bool autoconnect: true
    property string device: ""

    // IPv4 settings
    property string ipv4Method: "auto"
    property string ipv4Address: ""
    property string ipv4Gateway: ""
    property string ipv4Dns: ""

    function open() {
        reset();
        visible = true;
        currentPage = 0;
    }

    function close() {
        visible = false;
        reset();
    }

    function reset() {
        currentPage = 0;
        connectionType = "";
        profileName = "";
        ssid = "";
        security = "wpa-psk";
        password = "";
        hidden = false;
        autoconnect = true;
        device = "";
        ipv4Method = "auto";
        ipv4Address = "";
        ipv4Gateway = "";
        ipv4Dns = "";
    }

    function createConnection() {
        if (connectionType === "wifi") {
            let name = profileName || ssid;
            if (security === "none") {
                Network.createWifiConnection(name, ssid, "", hidden, autoconnect, ipv4Method, ipv4Address, ipv4Gateway, ipv4Dns);
            } else {
                Network.createWifiConnection(name, ssid, password, hidden, autoconnect, ipv4Method, ipv4Address, ipv4Gateway, ipv4Dns);
            }
        } else if (connectionType === "ethernet") {
            let name = profileName || "Ethernet";
            Network.createEthernetConnection(name, device, autoconnect, ipv4Method, ipv4Address, ipv4Gateway, ipv4Dns);
        }
        close();
    }

    function canProceed() {
        if (currentPage === 0) return connectionType !== "";
        if (currentPage === 1) {
            if (connectionType === "wifi") {
                if (!ssid) return false;
                if (security !== "none" && password.length < 8) return false;
                return true;
            }
            return true;
        }
        return true;
    }

    function nextPage() {
        if (currentPage < 2) currentPage++;
    }

    function prevPage() {
        if (currentPage > 0) currentPage--;
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
        Column {
            id: dialogHeader
            width: parent.width
            spacing: 8

            // Title row
            Item {
                width: parent.width
                height: 32

                Row {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12

                    MaterialIcon {
                        visible: dialog.currentPage > 0
                        name: "arrow_back"
                        size: 20
                        color: backMouse.containsMouse ? Colors.primary : Colors.foreground
                        anchors.verticalCenter: parent.verticalCenter

                        MouseArea {
                            id: backMouse
                            anchors.fill: parent
                            anchors.margins: -8
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: dialog.prevPage()
                        }
                    }

                    CustomText {
                        text: {
                            if (dialog.currentPage === 0) return "New Connection";
                            if (dialog.currentPage === 1) {
                                if (dialog.connectionType === "wifi") return "Wi-Fi Settings";
                                if (dialog.connectionType === "ethernet") return "Ethernet Settings";
                                return "Connection Settings";
                            }
                            return "Advanced Settings";
                        }
                        font.bold: true
                        size: Fonts.sizing.large
                        anchors.verticalCenter: parent.verticalCenter
                    }
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

            // Page indicator
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6

                Repeater {
                    model: 3
                    CustomRect {
                        width: dialog.currentPage === index ? 16 : 6
                        height: 6
                        radius: 3
                        color: dialog.currentPage === index ? Colors.primary : Colors.darkSurface

                        Behavior on width { NumberAnimation { duration: 150 } }
                    }
                }
            }
        }

        // Content
        Item {
            id: contentArea
            anchors.top: dialogHeader.bottom
            anchors.bottom: footerArea.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: Sizing.spacing.small
            anchors.bottomMargin: Sizing.spacing.small
            clip: true

            // Page 0: Connection Type
            Item {
                anchors.fill: parent
                visible: dialog.currentPage === 0
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Column {
                    anchors.fill: parent
                    spacing: 8

                    CustomText {
                        text: "Select connection type"
                        size: 11
                        opacity: 0.6
                    }

                    TypeOption {
                        width: parent.width
                        icon: "wifi"
                        title: "Wi-Fi"
                        description: "Connect to a wireless network"
                        selected: dialog.connectionType === "wifi"
                        onClicked: dialog.connectionType = "wifi"
                    }

                    TypeOption {
                        width: parent.width
                        icon: "settings_ethernet"
                        title: "Ethernet"
                        description: "Wired network connection"
                        selected: dialog.connectionType === "ethernet"
                        onClicked: dialog.connectionType = "ethernet"
                    }

                    TypeOption {
                        width: parent.width
                        icon: "vpn_lock"
                        title: "VPN"
                        description: "WireGuard or OpenVPN tunnel"
                        selected: dialog.connectionType === "vpn"
                        enabled: false
                        onClicked: dialog.connectionType = "vpn"
                    }
                }
            }

            // Page 1: Connection Details
            ScrollView {
                anchors.fill: parent
                visible: dialog.currentPage === 1
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Column {
                    width: contentArea.width
                    spacing: 16

                    // Wi-Fi Settings
                    Column {
                        width: parent.width
                        spacing: 16
                        visible: dialog.connectionType === "wifi"

                        FormField {
                            width: parent.width
                            label: "SSID (Network Name)"
                            placeholderText: "Enter network name"
                            text: dialog.ssid
                            onTextChanged: dialog.ssid = text
                        }

                        Column {
                            width: parent.width
                            spacing: 6

                            CustomText {
                                text: "Security"
                                size: 11
                                opacity: 0.7
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                OptionChip {
                                    text: "WPA/WPA2"
                                    selected: dialog.security === "wpa-psk"
                                    onClicked: dialog.security = "wpa-psk"
                                }

                                OptionChip {
                                    text: "WPA3"
                                    selected: dialog.security === "sae"
                                    onClicked: dialog.security = "sae"
                                }

                                OptionChip {
                                    text: "None"
                                    selected: dialog.security === "none"
                                    onClicked: dialog.security = "none"
                                }
                            }
                        }

                        FormField {
                            width: parent.width
                            visible: dialog.security !== "none"
                            label: "Password"
                            placeholderText: "Enter password (min 8 chars)"
                            text: dialog.password
                            isPassword: true
                            onTextChanged: dialog.password = text
                        }

                        FormCheckbox {
                            width: parent.width
                            label: "Hidden network"
                            description: "Network doesn't broadcast its name"
                            checked: dialog.hidden
                            onToggled: dialog.hidden = checked
                        }
                    }

                    // Ethernet Settings
                    Column {
                        width: parent.width
                        spacing: 16
                        visible: dialog.connectionType === "ethernet"

                        Column {
                            width: parent.width
                            spacing: 6

                            CustomText {
                                text: "Device"
                                size: 11
                                opacity: 0.7
                            }

                            CustomText {
                                text: "Leave empty for automatic selection"
                                size: 10
                                opacity: 0.4
                            }

                            CustomRect {
                                width: parent.width
                                height: 40
                                color: Colors.darkSurface
                                radius: Sizing.radius.small

                                TextInput {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    color: Colors.foreground
                                    font.pixelSize: Fonts.sizing.small
                                    font.family: "FiraCode Nerd Font Mono"
                                    text: dialog.device
                                    onTextChanged: dialog.device = text

                                    Text {
                                        anchors.fill: parent
                                        text: "e.g., eth0, enp6s0"
                                        color: Colors.foreground
                                        opacity: 0.3
                                        font: parent.font
                                        visible: !parent.text
                                    }
                                }
                            }
                        }
                    }

                    // Common settings
                    FormCheckbox {
                        width: parent.width
                        label: "Connect automatically"
                        description: "Auto-connect when this network is available"
                        checked: dialog.autoconnect
                        onToggled: dialog.autoconnect = checked
                    }

                    FormField {
                        width: parent.width
                        label: "Profile name (optional)"
                        placeholderText: dialog.connectionType === "wifi" ? dialog.ssid || "Connection name" : "Ethernet"
                        text: dialog.profileName
                        onTextChanged: dialog.profileName = text
                    }
                }
            }

            // Page 2: Advanced Settings
            ScrollView {
                anchors.fill: parent
                visible: dialog.currentPage === 2
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                Column {
                    width: contentArea.width
                    spacing: 16

                    CustomText {
                        text: "IPv4 CONFIGURATION"
                        size: 10
                        font.bold: true
                        opacity: 0.5
                        color: Colors.primary
                    }

                    Column {
                        width: parent.width
                        spacing: 6

                        CustomText {
                            text: "Method"
                            size: 11
                            opacity: 0.7
                        }

                        Row {
                            width: parent.width
                            spacing: 8

                            OptionChip {
                                text: "Automatic (DHCP)"
                                selected: dialog.ipv4Method === "auto"
                                onClicked: dialog.ipv4Method = "auto"
                            }

                            OptionChip {
                                text: "Manual"
                                selected: dialog.ipv4Method === "manual"
                                onClicked: dialog.ipv4Method = "manual"
                            }

                            OptionChip {
                                text: "Disabled"
                                selected: dialog.ipv4Method === "disabled"
                                onClicked: dialog.ipv4Method = "disabled"
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 12
                        visible: dialog.ipv4Method === "manual"
                        opacity: visible ? 1 : 0.5

                        FormField {
                            width: parent.width
                            label: "Address"
                            placeholderText: "192.168.1.100/24"
                            text: dialog.ipv4Address
                            onTextChanged: dialog.ipv4Address = text
                        }

                        FormField {
                            width: parent.width
                            label: "Gateway"
                            placeholderText: "192.168.1.1"
                            text: dialog.ipv4Gateway
                            onTextChanged: dialog.ipv4Gateway = text
                        }

                        FormField {
                            width: parent.width
                            label: "DNS Servers"
                            placeholderText: "8.8.8.8, 1.1.1.1"
                            text: dialog.ipv4Dns
                            onTextChanged: dialog.ipv4Dns = text
                        }
                    }

                    Item { width: 1; height: 8 }

                    CustomText {
                        text: "IPv6 CONFIGURATION"
                        size: 10
                        font.bold: true
                        opacity: 0.5
                        color: Colors.primary
                    }

                    CustomText {
                        text: "IPv6 will be configured automatically"
                        size: 11
                        opacity: 0.5
                    }
                }
            }
        }

        // Footer
        Item {
            id: footerArea
            anchors.bottom: parent.bottom
            width: parent.width
            height: 50

            RowLayout {
                anchors.fill: parent
                spacing: 12

                CustomText {
                    Layout.fillWidth: true
                    text: {
                        if (dialog.currentPage === 1 && dialog.connectionType === "wifi") {
                            if (!dialog.ssid) return "Enter network name";
                            if (dialog.security !== "none" && dialog.password.length < 8) return "Password must be 8+ characters";
                        }
                        return "";
                    }
                    size: 10
                    opacity: 0.5
                    color: Colors.warning
                }

                DialogButton {
                    text: "Cancel"
                    onClicked: dialog.close()
                }

                DialogButton {
                    visible: dialog.currentPage < 2
                    text: "Next"
                    primary: true
                    enabled: dialog.canProceed()
                    onClicked: dialog.nextPage()
                }

                DialogButton {
                    visible: dialog.currentPage === 2
                    text: "Create"
                    primary: true
                    enabled: dialog.canProceed()
                    onClicked: dialog.createConnection()
                }
            }
        }
    }

    // Components
    component TypeOption: CustomRect {
        id: typeOpt
        property string icon
        property string title
        property string description
        property bool selected: false
        signal clicked

        height: 64
        radius: Sizing.radius.small
        color: selected ? Colors.primary : (typeOptMouse.containsMouse ? Colors.darkSurface : "transparent")
        border.color: selected ? Colors.primary : Colors.darkSurface
        border.width: 1
        opacity: enabled ? 1.0 : 0.4

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            CustomRect {
                width: 40; height: 40
                radius: 20
                color: typeOpt.selected ? Colors.primaryContrast : Colors.darkSurface

                MaterialIcon {
                    anchors.centerIn: parent
                    name: typeOpt.icon
                    size: 20
                    color: typeOpt.selected ? Colors.primary : Colors.foreground
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: 2

                CustomText {
                    text: typeOpt.title
                    font.bold: true
                    size: Fonts.sizing.small
                    color: typeOpt.selected ? Colors.primaryContrast : Colors.foreground
                }

                CustomText {
                    text: typeOpt.description
                    size: 10
                    opacity: 0.6
                    color: typeOpt.selected ? Colors.primaryContrast : Colors.foreground
                }
            }

            MaterialIcon {
                visible: typeOpt.selected
                name: "check_circle"
                size: 20
                color: Colors.primaryContrast
            }
        }

        MouseArea {
            id: typeOptMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (enabled) typeOpt.clicked()
        }
    }

    component FormField: Column {
        id: formFieldRoot
        property string label
        property string placeholderText
        property alias text: fieldInput.text
        property bool isPassword: false
        property bool showPasswordToggle: true

        spacing: 6

        CustomText {
            text: formFieldRoot.label
            size: 11
            opacity: 0.7
        }

        CustomRect {
            width: formFieldRoot.width
            height: 40
            color: Colors.darkSurface
            radius: Sizing.radius.small
            border.color: fieldInput.activeFocus ? Colors.primary : "transparent"
            border.width: 2

            TextInput {
                id: fieldInput
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: formFieldRoot.isPassword && formFieldRoot.showPasswordToggle ? 40 : 12
                color: Colors.foreground
                font.pixelSize: Fonts.sizing.small
                font.family: "FiraCode Nerd Font Mono"
                echoMode: formFieldRoot.isPassword && !showPwdToggle.checked ? TextInput.Password : TextInput.Normal
                clip: true
                selectByMouse: true
                verticalAlignment: TextInput.AlignVCenter

                Text {
                    anchors.fill: parent
                    text: formFieldRoot.placeholderText
                    color: Colors.foreground
                    opacity: 0.3
                    font: parent.font
                    verticalAlignment: Text.AlignVCenter
                    visible: !parent.text
                }
            }

            MaterialIcon {
                visible: formFieldRoot.isPassword && formFieldRoot.showPasswordToggle
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                name: showPwdToggle.checked ? "visibility" : "visibility_off"
                size: 18
                opacity: 0.5
                color: Colors.foreground

                MouseArea {
                    id: showPwdToggle
                    property bool checked: false
                    anchors.fill: parent
                    anchors.margins: -5
                    cursorShape: Qt.PointingHandCursor
                    onClicked: checked = !checked
                }
            }
        }
    }

    component FormCheckbox: CustomRect {
        id: checkboxRoot
        property string label
        property string description
        property bool checked: false
        signal toggled

        height: 52
        color: checkMouse.containsMouse ? Colors.darkSurface : "transparent"
        radius: Sizing.radius.small

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 12

            CustomRect {
                width: 22; height: 22
                radius: 4
                color: checkboxRoot.checked ? Colors.primary : "transparent"
                border.color: checkboxRoot.checked ? Colors.primary : Colors.darkSurface
                border.width: 2

                MaterialIcon {
                    anchors.centerIn: parent
                    name: "check"
                    size: 16
                    color: Colors.primaryContrast
                    visible: checkboxRoot.checked
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: 2

                CustomText {
                    text: checkboxRoot.label
                    size: Fonts.sizing.small
                }

                CustomText {
                    text: checkboxRoot.description
                    size: 10
                    opacity: 0.5
                    visible: text !== ""
                }
            }
        }

        MouseArea {
            id: checkMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                checkboxRoot.checked = !checkboxRoot.checked;
                checkboxRoot.toggled();
            }
        }
    }

    component OptionChip: CustomRect {
        property string text
        property bool selected: false
        signal clicked

        width: chipText.implicitWidth + 24
        height: 32
        radius: 16
        color: selected ? Colors.primary : "transparent"
        border.color: selected ? Colors.primary : Colors.darkSurface
        border.width: 1

        CustomText {
            id: chipText
            anchors.centerIn: parent
            text: parent.text
            size: 11
            color: parent.selected ? Colors.primaryContrast : Colors.foreground
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component DialogButton: CustomRect {
        property string text
        property bool primary: false
        signal clicked

        width: Math.max(90, btnText.implicitWidth + 32)
        height: 38
        radius: Sizing.radius.small
        color: {
            if (!enabled) return Colors.darkSurface;
            if (primary) return dialogBtnMouse.containsMouse ? Qt.lighter(Colors.primary, 1.1) : Colors.primary;
            return dialogBtnMouse.containsMouse ? Colors.darkSurface : "transparent";
        }
        border.color: primary ? "transparent" : Colors.darkSurface
        border.width: 1
        opacity: enabled ? 1.0 : 0.5

        CustomText {
            id: btnText
            anchors.centerIn: parent
            text: parent.text
            size: Fonts.sizing.small
            font.bold: parent.primary
            color: parent.primary ? Colors.primaryContrast : Colors.foreground
        }

        MouseArea {
            id: dialogBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (enabled) parent.clicked()
        }
    }
}
