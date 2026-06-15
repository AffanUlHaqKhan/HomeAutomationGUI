import QtQuick
import HomeAuto

// Filled line chart for a series of numbers.
Item {
    id: root
    property var values: []
    property color lineColor: Theme.accent
    property real minValue: NaN   // auto if NaN
    property real maxValue: NaN
    property real padding: 4

    onValuesChanged: canvas.requestPaint()
    onLineColorChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const vals = root.values;
            const n = vals ? vals.length : 0;
            if (n < 2)
                return;

            let mn = root.minValue, mx = root.maxValue;
            if (isNaN(mn) || isNaN(mx)) {
                mn = Infinity; mx = -Infinity;
                for (let i = 0; i < n; ++i) {
                    mn = Math.min(mn, vals[i]);
                    mx = Math.max(mx, vals[i]);
                }
            }
            if (mx - mn < 0.001) { mx += 0.5; mn -= 0.5; }

            const pad = root.padding;
            const w = width - pad * 2;
            const h = height - pad * 2;
            const dx = w / (n - 1);
            const yOf = v => pad + h - ((v - mn) / (mx - mn)) * h;

            // Area fill
            ctx.beginPath();
            ctx.moveTo(pad, height - pad);
            for (let i = 0; i < n; ++i)
                ctx.lineTo(pad + i * dx, yOf(vals[i]));
            ctx.lineTo(pad + (n - 1) * dx, height - pad);
            ctx.closePath();
            const grad = ctx.createLinearGradient(0, 0, 0, height);
            grad.addColorStop(0, Qt.alpha(root.lineColor, 0.30));
            grad.addColorStop(1, Qt.alpha(root.lineColor, 0.0));
            ctx.fillStyle = grad;
            ctx.fill();

            // Line
            ctx.beginPath();
            ctx.lineWidth = 2;
            ctx.lineJoin = "round";
            ctx.strokeStyle = root.lineColor;
            for (let i = 0; i < n; ++i) {
                const x = pad + i * dx, y = yOf(vals[i]);
                if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
            }
            ctx.stroke();

            // End dot
            ctx.beginPath();
            ctx.fillStyle = root.lineColor;
            ctx.arc(pad + (n - 1) * dx, yOf(vals[n - 1]), 3, 0, Math.PI * 2);
            ctx.fill();
        }
    }
}
