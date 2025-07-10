pragma Singleton

import Quickshell

Singleton {
    property var backgrounds: ({})

    function setWallpaper(monitorModel, wallpaperPath) {
        if (typeof monitorModel !== 'string' || monitorModel.trim() === '') {
            console.warn("setWallpaper: monitorModel inválido.");
            return;
        }

        var newBackgrounds = {};
        for (var key in backgrounds) {
            newBackgrounds[key] = backgrounds[key];
        }
        newBackgrounds[monitorModel] = wallpaperPath;
        backgrounds = newBackgrounds;
    }
}
