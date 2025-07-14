pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    property var backgrounds: {
        try {
            return JSON.parse(file.text());
        } catch (error) {
            return {};
        }
    }

    function setWallpaper(monitorModel, wallpaperPath) {
        if (typeof monitorModel !== 'string' || monitorModel.trim() === '') {
            return;
        }

        var newBackgrounds = {};
        for (var key in backgrounds) {
            newBackgrounds[key] = backgrounds[key];
        }
        newBackgrounds[monitorModel] = wallpaperPath;
        backgrounds = newBackgrounds;
        file.setText(JSON.stringify(backgrounds, null, 2));
    }

    FileView {
        id: file
        path: Qt.resolvedUrl(Quickshell.dataPath("../../backgrounds.json"))
    }
}
