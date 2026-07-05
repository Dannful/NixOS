import QtQuick
import "root:/core"

Canvas {
    id: root
    property var values: []
    property color lineColor: Colors.primary
    property real maxValue: 0

    onValuesChanged: requestPaint()
    onLineColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        if (values.length < 2) return;

        const peak = Math.max(maxValue, ...values, 1);
        const stepX = width / (values.length - 1);

        ctx.beginPath();
        for (let i = 0; i < values.length; i++) {
            const x = i * stepX;
            const y = height - (values[i] / peak) * height;
            if (i === 0) ctx.moveTo(x, y);
            else ctx.lineTo(x, y);
        }
        ctx.lineTo(width, height);
        ctx.lineTo(0, height);
        ctx.closePath();
        ctx.fillStyle = Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.2);
        ctx.fill();

        ctx.beginPath();
        for (let i = 0; i < values.length; i++) {
            const x = i * stepX;
            const y = height - (values[i] / peak) * height;
            if (i === 0) ctx.moveTo(x, y);
            else ctx.lineTo(x, y);
        }
        ctx.strokeStyle = lineColor;
        ctx.lineWidth = 1.5;
        ctx.stroke();
    }
}
