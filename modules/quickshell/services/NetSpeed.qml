pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int historyLength: 60

    property real rxRate: 0
    property real txRate: 0
    property real sessionRxBytes: 0
    property real sessionTxBytes: 0
    property var rxHistory: []
    property var txHistory: []

    property real _prevRx: -1
    property real _prevTx: -1

    function humanBytes(bytes) {
        if (bytes < 1024) return bytes.toFixed(0) + " B";
        if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + " KB";
        if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + " MB";
        return (bytes / (1024 * 1024 * 1024)).toFixed(2) + " GB";
    }

    function humanRate(bytesPerSec) {
        return humanBytes(bytesPerSec) + "/s";
    }

    function _pushHistory(list, value) {
        const next = list.concat([value]);
        while (next.length > root.historyLength) next.shift();
        return next;
    }

    Process {
        id: monitor
        running: true
        command: ["bash", "-c", "d=$(mktemp -d); mkfifo \"$d/p\"; exec 3<>\"$d/p\"; rm -rf \"$d\"; while true; do rx=0; tx=0; while IFS= read -r line; do case \"$line\" in *:*) iface=\"${line%%:*}\"; iface=\"${iface// /}\"; if [ \"$iface\" != \"lo\" ]; then data=\"${line#*:}\"; set -- $data; rx=$((rx + $1)); tx=$((tx + $9)); fi ;; esac; done < /proc/net/dev; echo \"$rx,$tx\"; read -rt1 <&3 || true; done"]
        stdout: SplitParser {
            onRead: line => {
                const parts = line.trim().split(",");
                if (parts.length < 2) return;
                const rx = parseFloat(parts[0]);
                const tx = parseFloat(parts[1]);
                if (root._prevRx >= 0) {
                    root.rxRate = Math.max(0, rx - root._prevRx);
                    root.txRate = Math.max(0, tx - root._prevTx);
                    root.sessionRxBytes += root.rxRate;
                    root.sessionTxBytes += root.txRate;
                    root.rxHistory = root._pushHistory(root.rxHistory, root.rxRate);
                    root.txHistory = root._pushHistory(root.txHistory, root.txRate);
                }
                root._prevRx = rx;
                root._prevTx = tx;
            }
        }
    }
}
