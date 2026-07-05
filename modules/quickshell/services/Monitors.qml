pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var monitors: []
    // Draft edits keyed by monitor name, not yet sent to Hyprland: { width, height, refreshRate, x, y }
    property var pending: ({})
    property bool busy: false
    property string lastError: ""

    property var _applyQueue: []

    function refresh() {
        root.busy = true;
        query.running = false;
        query.running = true;
    }

    function hasPending() {
        return Object.keys(root.pending).length > 0;
    }

    function isPending(name) {
        return !!root.pending[name];
    }

    // Merges any staged edits on top of the live-queried monitor state
    function effective(monitor) {
        const patch = root.pending[monitor.name];
        return patch ? Object.assign({}, monitor, patch) : monitor;
    }

    function _stage(name, patch) {
        const next = Object.assign({}, root.pending);
        next[name] = Object.assign({}, next[name] || {}, patch);
        root.pending = next;
    }

    function stageMode(monitor, modeString) {
        // modeString like "1920x1080@144.00Hz"
        const match = modeString.match(/(\d+)x(\d+)@([\d.]+)/);
        if (!match) return;
        root._stage(monitor.name, {
            width: parseInt(match[1]),
            height: parseInt(match[2]),
            refreshRate: Math.round(parseFloat(match[3]))
        });
    }

    function stagePosition(monitor, x, y) {
        root._stage(monitor.name, { x: Math.round(x), y: Math.round(y) });
    }

    function discardAll() {
        root.pending = {};
    }

    // Given a monitor being dragged to (proposedX, proposedY) in logical (layout) pixels,
    // always resolve to sitting left-of/right-of/above/below whichever neighbor edge is
    // nearest (relative positioning) rather than an arbitrary absolute position. Only when
    // there is no other monitor to be relative to do we fall back to a plain grid snap.
    function snapPosition(monitor, proposedX, proposedY) {
        const eff = root.effective(monitor);
        const w = eff.width / eff.scale;
        const h = eff.height / eff.scale;

        const others = root.monitors.filter(m => m.name !== monitor.name);
        if (others.length === 0) {
            return { x: Math.round(proposedX / 10) * 10, y: Math.round(proposedY / 10) * 10 };
        }

        let bestDist = Infinity;
        let snapped = null;

        for (const other of others) {
            const oEff = root.effective(other);
            const ow = oEff.width / oEff.scale;
            const oh = oEff.height / oEff.scale;

            // Clamp the aligned axis so the two monitors always keep some overlap,
            // instead of drifting past each other on an infinite edge line.
            const alignedX = Math.min(Math.max(proposedX, oEff.x - w + 1), oEff.x + ow - 1);
            const alignedY = Math.min(Math.max(proposedY, oEff.y - h + 1), oEff.y + oh - 1);

            const candidates = [
                { x: oEff.x + ow, y: alignedY },   // right-of other
                { x: oEff.x - w, y: alignedY },    // left-of other
                { x: alignedX, y: oEff.y + oh },   // below other
                { x: alignedX, y: oEff.y - h }     // above other
            ];

            for (const c of candidates) {
                const dist = Math.hypot(proposedX - c.x, proposedY - c.y);
                if (dist < bestDist) {
                    bestDist = dist;
                    snapped = c;
                }
            }
        }

        return snapped;
    }

    function applyAll() {
        const specs = [];
        for (const name in root.pending) {
            const live = root.monitors.find(m => m.name === name);
            if (!live) continue;
            const eff = root.effective(live);
            specs.push(name + "," + eff.width + "x" + eff.height + "@" + eff.refreshRate + "," + eff.x + "x" + eff.y + "," + eff.scale);
        }
        if (specs.length === 0) return;
        root._applyQueue = specs;
        root._runNextApply();
    }

    function _runNextApply() {
        if (root._applyQueue.length === 0) {
            root.pending = {};
            root.refresh();
            return;
        }
        const spec = root._applyQueue.shift();
        applyProcess.command = ["hyprctl", "keyword", "monitor", spec];
        root.busy = true;
        applyProcess.running = false;
        applyProcess.running = true;
    }

    Process {
        id: query
        running: false
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.busy = false;
                try {
                    root.monitors = JSON.parse(text);
                    root.lastError = "";
                } catch (e) {
                    root.lastError = "Failed to read monitor state";
                }
            }
        }
    }

    Process {
        id: applyProcess
        running: false
        command: ["true"]
        onExited: (exitCode) => {
            if (exitCode !== 0) root.lastError = "Failed to apply monitor change";
            root._runNextApply();
        }
    }
}
