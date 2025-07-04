pragma Singleton

import Quickshell
import QtQuick
import Quickshell.Io

Singleton {
    id: root
    readonly property list<Network> networks: []
    readonly property Network currentNetwork: networks.find(network => network.connected) ?? null
    reloadableId: "network"

    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: networkInspector.running = true
        }
    }

    Process {
        id: networkInspector
        running: true
        command: ["nmcli", "-g", "SSID,ACTIVE,SIGNAL,FREQ", "device", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                const networks = text.trim().split("\n").map(network => {
                    const networkChunks = network.split(":");
                    return {
                        ssid: networkChunks[0] || "",
                        connected: networkChunks[1] === "yes",
                        strength: parseInt(networkChunks[2]),
                        frequency: parseInt(networkChunks[3].split(" ")[0])
                    };
                });
                const toBeDeleted = root.networks.filter(rootNetwork => networks.find(currentNetwork => currentNetwork.ssid !== rootNetwork.ssid || currentNetwork.strength !== rootNetwork.strength || currentNetwork.frequency !== rootNetwork.frequency || currentNetwork.connected !== rootNetwork.connected));
                for (const element of toBeDeleted) {
                    root.networks.splice(root.networks.indexOf(element), 1).forEach(o => o.destroy());
                }
                for (const network of networks) {
                    const existingNetwork = root.networks.find(n => n.ssid === network.ssid && n.strength === network.strength && n.frequency === network.frequency && n.connected === network.connected);
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
