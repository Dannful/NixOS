pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property real latitude: 0
    property real longitude: 0
    property string locationName: ""

    property real currentTemp: 0
    property string currentIcon: "sunny"
    property var daily: []

    function _iconFor(code) {
        if (code === 0) return "sunny";
        if (code <= 2) return "partly_cloudy_day";
        if (code === 3) return "cloudy";
        if (code === 45 || code === 48) return "foggy";
        if (code >= 51 && code <= 67) return "rainy";
        if (code >= 71 && code <= 77) return "weather_snowy";
        if (code >= 80 && code <= 82) return "rainy";
        if (code >= 85 && code <= 86) return "weather_snowy";
        if (code >= 95) return "thunderstorm";
        return "cloud";
    }

    Timer {
        interval: 0
        running: true
        onTriggered: locate.running = true
    }

    Timer {
        interval: 15 * 60 * 1000
        running: root.latitude !== 0 || root.longitude !== 0
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            forecast.running = false;
            forecast.running = true;
        }
    }

    Process {
        id: locate
        running: false
        command: ["curl", "-s", "--max-time", "5", "https://ipapi.co/json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.latitude = data.latitude || 0;
                    root.longitude = data.longitude || 0;
                    root.locationName = data.city || "";
                } catch (e) {
                    // No network / geolocation unavailable — weather stays hidden
                }
            }
        }
    }

    Process {
        id: forecast
        running: false
        command: ["curl", "-s", "--max-time", "5",
            "https://api.open-meteo.com/v1/forecast?latitude=" + root.latitude +
            "&longitude=" + root.longitude +
            "&current=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min,weather_code&timezone=auto"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.currentTemp = data.current.temperature_2m;
                    root.currentIcon = root._iconFor(data.current.weather_code);
                    const days = [];
                    for (let i = 0; i < data.daily.time.length; i++) {
                        days.push({
                            date: data.daily.time[i],
                            hi: data.daily.temperature_2m_max[i],
                            lo: data.daily.temperature_2m_min[i],
                            icon: root._iconFor(data.daily.weather_code[i])
                        });
                    }
                    root.daily = days;
                    root.available = true;
                } catch (e) {
                    root.available = false;
                }
            }
        }
    }
}
