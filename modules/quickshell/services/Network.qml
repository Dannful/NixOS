pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root
    readonly property list<Network> networks: []
    readonly property Network currentNetwork: networks.find(network => network.connected) ?? null
    property bool wifiEnabled: true
    property bool scanning: false
    property string connectingSsid: ""
    property bool updatesFrozen: false
    property bool isConnecting: false
    property bool isDisconnecting: false
    reloadableId: "network"
    
    onWifiEnabledChanged: {
        if (wifiEnabled) {
            scanDelay.restart();
        }
    }
    
    Timer {
        id: scanDelay
        interval: 2000
        repeat: false
        onTriggered: scan()
    }

    Timer {
        id: scanCooldown
        interval: 4000
        onTriggered: {
            root.scanning = false
            networkInspector.running = true
        }
    }

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: data => {
                networkInspector.running = true
                checkWifiStatus.running = true
            }
        }
    }

    Process {
        id: checkWifiStatus
        running: true
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser {
            onRead: data => root.wifiEnabled = data.trim() === "enabled"
        }
    }

    Process {
        id: commandRunner
        
        onRunningChanged: {
            if (!running) {
                root.isConnecting = false;
                root.isDisconnecting = false;
                root.connectingSsid = "";
                
                checkWifiStatus.running = true
                networkInspector.running = true
            }
        }
    }

    Process {
        id: wifiRescan
        command: ["nmcli", "device", "wifi", "rescan"]
        onRunningChanged: {
            if (!running) {
                // Rescan finished, refresh the list
                networkInspector.running = true
            }
        }
    }

    function escapeArg(arg) {
        return "'" + arg.replace(/'/g, "'\\''") + "'";
    }

    function scan() {
        if (!wifiEnabled) return;
        scanning = true;
        scanCooldown.restart();
        wifiRescan.running = true;
    }

    function connect(ssid, password) {
        connectingSsid = ssid;
        isConnecting = true;
        
        var cmd = "";
        if (password && password !== "") {
            // If password is provided, we delete the old connection to force a fresh 
            // connection with the new credentials. This fixes the "property missing" error
            // by ensuring nmcli derives security settings from the current scan results.
            cmd = "nmcli connection delete id " + escapeArg(ssid) + " >/dev/null 2>&1; ";
            cmd += "output=$(nmcli device wifi connect " + escapeArg(ssid) + " password " + escapeArg(password) + " 2>&1); res=$?; ";
        } else {
            cmd = "output=$(nmcli device wifi connect " + escapeArg(ssid) + " 2>&1); res=$?; ";
        }
        
        cmd += "if [ $res -eq 0 ]; then ";
        cmd += "notify-send 'Wi-Fi' 'Connected to " + escapeArg(ssid) + "'; ";
        cmd += "else ";
        cmd += "notify-send -u critical 'Wi-Fi' \"Failed to connect to " + escapeArg(ssid) + "\n$output\"; ";
        cmd += "fi";
        
        commandRunner.command = ["bash", "-c", cmd];
        commandRunner.running = true;
    }

    function disconnect(ssid) {
        isDisconnecting = true;
        
        var cmd = "output=$(nmcli connection down id " + escapeArg(ssid) + " 2>&1); res=$?; ";
        cmd += "if [ $res -eq 0 ]; then ";
        cmd += "notify-send 'Wi-Fi' 'Disconnected'; ";
        cmd += "else ";
        cmd += "notify-send -u critical 'Wi-Fi' \"Failed to disconnect\n$output\"; ";
        cmd += "fi";

        commandRunner.command = ["bash", "-c", cmd];
        commandRunner.running = true;
    }

    function toggleWifi(enable) {
        commandRunner.command = ["nmcli", "radio", "wifi", enable ? "on" : "off"];
        commandRunner.running = true;
    }

    Process {
        id: networkInspector
        running: true
        command: ["nmcli", "-g", "SSID,ACTIVE,SIGNAL,FREQ", "device", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.updatesFrozen) return;

                if (!scanCooldown.running) {
                    root.scanning = false; 
                }
                
                // Temporary map to handle deduplication by SSID
                const uniqueNetworks = {};

                text.trim().split("\n").forEach(network => {
                    if (!network.trim()) return;
                    
                    const networkChunks = network.split(":");
                    if (networkChunks.length < 4) return;
                    
                    const ssid = networkChunks[0]; 
                    // Filter out hidden/empty SSIDs
                    if (!ssid || ssid.trim() === "") return;

                    const connected = networkChunks[1] === "yes";
                    const strength = parseInt(networkChunks[2]) || 0;
                    const freqStr = networkChunks[3] || "";
                    const frequency = parseInt(freqStr.split(" ")[0]) || 0;
                    
                    const newEntry = {
                        ssid: ssid,
                        connected: connected,
                        strength: strength,
                        frequency: frequency
                    };

                    // Logic: prefer connected network, then stronger signal
                    if (!uniqueNetworks[ssid]) {
                        uniqueNetworks[ssid] = newEntry;
                    } else {
                        const existing = uniqueNetworks[ssid];
                        if (newEntry.connected) {
                            uniqueNetworks[ssid] = newEntry;
                        } else if (!existing.connected && newEntry.strength > existing.strength) {
                            uniqueNetworks[ssid] = newEntry;
                        }
                    }
                });

                const networks = Object.values(uniqueNetworks);

                const toBeDeleted = root.networks.filter(rootNetwork => 
                    !networks.find(currentNetwork => 
                        currentNetwork.ssid === rootNetwork.ssid && 
                        currentNetwork.strength === rootNetwork.strength && 
                        currentNetwork.frequency === rootNetwork.frequency && 
                        currentNetwork.connected === rootNetwork.connected
                    )
                );
                
                for (const element of toBeDeleted) {
                    root.networks.splice(root.networks.indexOf(element), 1).forEach(o => o.destroy());
                }
                
                for (const network of networks) {
                    const existingNetwork = root.networks.find(n => 
                        n.ssid === network.ssid && 
                        n.strength === network.strength && 
                        n.frequency === network.frequency && 
                        n.connected === network.connected
                    );
                    
                    if (existingNetwork) {
                        existingNetwork.networkObject = network;
                    } else {
                        root.networks.push(networkComponent.createObject(root, {
                            networkObject: network
                        }));
                    }
                }
            }
        }
    }

    component Network: QtObject {
        required property var networkObject
        readonly property string ssid: networkObject.ssid
        readonly property int strength: networkObject.strength
        readonly property int frequency: networkObject.frequency
        readonly property bool connected: networkObject.connected
    }

    Component {
        id: networkComponent
        Network {}
    }
}