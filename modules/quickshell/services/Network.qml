pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root

    property var connections: []
    property bool wifiEnabled: false
    property bool scanning: false
    property bool vpnConnected: false
    property bool ethernetConnected: false
    property var wifiScanResults: []

    property bool busy: false
    property string status: ""
    property string pendingConnection: ""

    reloadableId: "network"

    function clearStatus() {
        root.status = "";
        root.pendingConnection = "";
    }

    Timer {
        id: statusTimer
        interval: 3000
        onTriggered: root.clearStatus()
    }

    function setStatus(msg, autoClear) {
        root.status = msg;
        if (autoClear) statusTimer.restart();
    }

    function update() {
        checkWifiStatus.running = false;
        checkWifiStatus.running = true;
        refreshConnections.running = false;
        refreshConnections.running = true;
        networkInspector.running = false;
        networkInspector.running = true;
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.update()
    }

    Process {
        id: checkWifiStatus
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text) return;
                root.wifiEnabled = text.trim() === "enabled";
            }
        }
    }

    Process {
        id: refreshConnections
        command: ["nmcli", "-t", "-e", "no", "-f", "NAME,TYPE,UUID,DEVICE,STATE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text) return;

                let lines = text.trim().split("\n");
                let profileMap = {};
                let vpn = false;
                let eth = false;

                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i];
                    let parts = line.split(":");
                    if (parts.length < 5) continue;

                    let connName = parts[0];
                    let connType = parts[1];
                    let connUuid = parts[2];
                    let connDevice = parts[3];
                    let connState = parts.slice(4).join(":");

                    if (!connName || connName === "lo" || connType === "bridge" || connType === "loopback") continue;
                    if (connName.indexOf("docker") >= 0 || connName.indexOf("br-") >= 0 || connName.indexOf("veth") >= 0) continue;

                    let isActive = connState.indexOf("activated") >= 0;
                    let isConnecting = connState.indexOf("activating") >= 0;

                    let isVpnType = connType.indexOf("vpn") >= 0 || connType === "wireguard";
                    let isEthType = connType.indexOf("ethernet") >= 0;

                    if (isActive && isVpnType) vpn = true;
                    if (isActive && isEthType) eth = true;

                    if (!profileMap[connName] || isActive || isConnecting) {
                        profileMap[connName] = {
                            connName: connName,
                            connType: connType,
                            connUuid: connUuid,
                            connDevice: connDevice,
                            connActive: isActive,
                            connConnecting: isConnecting
                        };
                    }
                }

                let finalConns = [];
                for (let key in profileMap) {
                    finalConns.push(profileMap[key]);
                }

                for (let j = 0; j < root.wifiScanResults.length; j++) {
                    let net = root.wifiScanResults[j];
                    if (!profileMap[net.ssid]) {
                        finalConns.push({
                            connName: net.ssid,
                            connUuid: "",
                            connType: "802-11-wireless",
                            connDevice: "",
                            connActive: net.connected,
                            connConnecting: false,
                            connSignal: net.strength,
                            connSecurity: net.security,
                            connUnsaved: true
                        });
                    }
                }

                finalConns.sort(function(a, b) {
                    if (a.connActive !== b.connActive) return b.connActive ? 1 : -1;
                    if (a.connConnecting !== b.connConnecting) return b.connConnecting ? 1 : -1;

                    function typeOrder(t) {
                        if (t.indexOf("vpn") >= 0 || t === "wireguard") return 0;
                        if (t.indexOf("ethernet") >= 0) return 1;
                        return 2;
                    }

                    let orderDiff = typeOrder(a.connType) - typeOrder(b.connType);
                    if (orderDiff !== 0) return orderDiff;
                    return a.connName.localeCompare(b.connName);
                });

                root.vpnConnected = vpn;
                root.ethernetConnected = eth;
                root.connections = finalConns;

                if (root.pendingConnection) {
                    for (let k = 0; k < finalConns.length; k++) {
                        if (finalConns[k].connName === root.pendingConnection && finalConns[k].connActive) {
                            root.setStatus("Connected to " + root.pendingConnection, true);
                            root.pendingConnection = "";
                            root.busy = false;
                            break;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: networkInspector
        command: ["nmcli", "-t", "-e", "no", "-f", "SSID,ACTIVE,SIGNAL,SECURITY", "device", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text) return;

                let lines = text.trim().split("\n");
                let results = [];
                let seen = {};

                for (let i = 0; i < lines.length; i++) {
                    let parts = lines[i].split(":");
                    if (parts.length < 4 || !parts[0]) continue;
                    if (seen[parts[0]]) continue;
                    seen[parts[0]] = true;

                    results.push({
                        ssid: parts[0],
                        connected: parts[1] === "yes",
                        strength: parseInt(parts[2]) || 0,
                        security: parts[3] || ""
                    });
                }

                root.wifiScanResults = results;
            }
        }
    }

    function toggleWifi(enable) {
        root.busy = true;
        root.setStatus(enable ? "Enabling Wi-Fi..." : "Disabling Wi-Fi...", false);
        let state = enable ? "on" : "off";
        commandRunner.command = ["nmcli", "radio", "wifi", state];
        commandRunner.running = true;
    }

    function scan() {
        if (!wifiEnabled) return;
        root.scanning = true;
        root.setStatus("Scanning...", false);
        wifiRescan.running = true;
    }

    function activateConnection(connUuid, connName) {
        root.busy = true;
        root.pendingConnection = connName;
        root.setStatus("Connecting to " + connName + "...", false);

        if (connUuid) {
            commandRunner.command = ["nmcli", "connection", "up", "uuid", connUuid];
        } else {
            commandRunner.command = ["nmcli", "device", "wifi", "connect", connName];
        }
        commandRunner.running = true;
    }

    function deactivateConnection(connUuid, connName, connDevice) {
        root.busy = true;
        root.setStatus("Disconnecting from " + connName + "...", false);

        if (connUuid) {
            commandRunner.command = ["nmcli", "connection", "down", "uuid", connUuid];
        } else if (connDevice) {
            commandRunner.command = ["nmcli", "device", "disconnect", connDevice];
        } else {
            commandRunner.command = ["nmcli", "connection", "down", connName];
        }
        commandRunner.running = true;
    }

    function deleteConnection(connUuid, connName) {
        if (connUuid) {
            root.busy = true;
            root.setStatus("Removing " + connName + "...", false);
            commandRunner.command = ["nmcli", "connection", "delete", "uuid", connUuid];
            commandRunner.running = true;
        }
    }

    function connectWifiWithPassword(ssid, password) {
        root.busy = true;
        root.pendingConnection = ssid;
        root.setStatus("Connecting to " + ssid + "...", false);
        commandRunner.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password];
        commandRunner.running = true;
    }

    // Create Wi-Fi connection with full options
    function createWifiConnection(name, ssid, password, hidden, autoconnect, ipv4Method, ipv4Address, ipv4Gateway, ipv4Dns) {
        root.busy = true;
        root.pendingConnection = name;
        root.setStatus("Creating " + name + "...", false);

        let cmd = ["nmcli", "connection", "add",
            "type", "wifi",
            "con-name", name,
            "ssid", ssid,
            "connection.autoconnect", autoconnect ? "yes" : "no"
        ];

        if (hidden) {
            cmd.push("wifi.hidden", "yes");
        }

        if (password) {
            cmd.push("wifi-sec.key-mgmt", "wpa-psk");
            cmd.push("wifi-sec.psk", password);
        }

        if (ipv4Method === "manual" && ipv4Address) {
            cmd.push("ipv4.method", "manual");
            cmd.push("ipv4.addresses", ipv4Address);
            if (ipv4Gateway) cmd.push("ipv4.gateway", ipv4Gateway);
            if (ipv4Dns) cmd.push("ipv4.dns", ipv4Dns.replace(/,\s*/g, " "));
        } else if (ipv4Method === "disabled") {
            cmd.push("ipv4.method", "disabled");
        }

        createConnectionRunner.connName = name;
        createConnectionRunner.command = cmd;
        createConnectionRunner.running = true;
    }

    // Create Ethernet connection with full options
    function createEthernetConnection(name, device, autoconnect, ipv4Method, ipv4Address, ipv4Gateway, ipv4Dns) {
        root.busy = true;
        root.pendingConnection = name;
        root.setStatus("Creating " + name + "...", false);

        let cmd = ["nmcli", "connection", "add",
            "type", "ethernet",
            "con-name", name,
            "connection.autoconnect", autoconnect ? "yes" : "no"
        ];

        if (device) {
            cmd.push("ifname", device);
        }

        if (ipv4Method === "manual" && ipv4Address) {
            cmd.push("ipv4.method", "manual");
            cmd.push("ipv4.addresses", ipv4Address);
            if (ipv4Gateway) cmd.push("ipv4.gateway", ipv4Gateway);
            if (ipv4Dns) cmd.push("ipv4.dns", ipv4Dns.replace(/,\s*/g, " "));
        } else if (ipv4Method === "disabled") {
            cmd.push("ipv4.method", "disabled");
        }

        createConnectionRunner.connName = name;
        createConnectionRunner.command = cmd;
        createConnectionRunner.running = true;
    }

    // Legacy functions for backward compatibility
    function addWifiConnection(ssid, password, autoconnect) {
        createWifiConnection(ssid, ssid, password, false, autoconnect, "auto", "", "", "");
    }

    function addOpenWifiConnection(ssid, autoconnect) {
        createWifiConnection(ssid, ssid, "", false, autoconnect, "auto", "", "", "");
    }

    Process {
        id: wifiRescan
        command: ["nmcli", "device", "wifi", "rescan"]
        onRunningChanged: {
            if (!running) {
                root.scanning = false;
                root.setStatus("Scan complete", true);
                root.update();
            }
        }
    }

    Process {
        id: commandRunner
        stdout: StdioCollector { onStreamFinished: {} }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                    root.setStatus("Error: " + text.trim().split("\n")[0], true);
                    root.busy = false;
                    root.pendingConnection = "";
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                root.update();
                if (!root.pendingConnection) {
                    root.busy = false;
                    if (!root.status.startsWith("Error")) {
                        root.setStatus("Done", true);
                    }
                }
            }
        }
    }

    Process {
        id: createConnectionRunner
        property string connName: ""

        stdout: StdioCollector { onStreamFinished: {} }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                    root.setStatus("Failed: " + text.trim().split("\n")[0], true);
                    root.busy = false;
                    root.pendingConnection = "";
                }
            }
        }
        onRunningChanged: {
            if (!running && connName) {
                root.setStatus("Connecting to " + connName + "...", false);
                activateRunner.command = ["nmcli", "connection", "up", connName];
                activateRunner.running = true;
            }
        }
    }

    Process {
        id: activateRunner
        stdout: StdioCollector { onStreamFinished: {} }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text && text.trim()) {
                    root.setStatus("Connection failed: " + text.trim().split("\n")[0], true);
                    root.busy = false;
                    root.pendingConnection = "";
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                root.update();
            }
        }
    }
}
