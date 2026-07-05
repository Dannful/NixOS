pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property string vendor: ""
    property real usage: 0
    property real temperature: 0
    property real vramUsedMb: 0
    property real vramTotalMb: 0

    readonly property string script: `
if command -v nvidia-smi >/dev/null 2>&1; then
  line=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null | head -n1 | tr -d " ")
  if [ -n "$line" ]; then echo "nvidia,$line"; exit 0; fi
fi
for c in /sys/class/drm/card*/device; do
  if [ -f "$c/uevent" ] && grep -q DRIVER=amdgpu "$c/uevent" 2>/dev/null; then
    busy=0; [ -f "$c/gpu_busy_percent" ] && busy=$(cat "$c/gpu_busy_percent")
    vused=0; [ -f "$c/mem_info_vram_used" ] && vused=$(cat "$c/mem_info_vram_used")
    vtotal=0; [ -f "$c/mem_info_vram_total" ] && vtotal=$(cat "$c/mem_info_vram_total")
    temp=0
    for h in "$c"/hwmon/hwmon*/temp1_input; do
      if [ -f "$h" ]; then temp=$(( $(cat "$h") / 1000 )); break; fi
    done
    echo "amd,$busy,$temp,$((vused/1048576)),$((vtotal/1048576))"
    exit 0
  fi
done
echo "none,0,0,0,0"
`

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            poll.running = false;
            poll.running = true;
        }
    }

    Process {
        id: poll
        running: false
        command: ["bash", "-c", root.script]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",");
                if (parts.length < 5 || parts[0] === "none") {
                    root.available = false;
                    return;
                }
                root.vendor = parts[0];
                root.usage = Math.max(0, Math.min(100, parseFloat(parts[1]) || 0)) / 100;
                root.temperature = parseFloat(parts[2]) || 0;
                root.vramUsedMb = parseFloat(parts[3]) || 0;
                root.vramTotalMb = parseFloat(parts[4]) || 0;
                root.available = true;
            }
        }
    }
}
