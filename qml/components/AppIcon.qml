import QtQuick

// Lightweight vector icons drawn with Canvas — no external assets required.
Canvas {
    id: root
    property string name: "bulb"
    property color color: "#ffffff"
    property real strokeWidth: 2.0

    width: 22
    height: 22
    antialiasing: true

    onColorChanged: requestPaint()
    onNameChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        ctx.lineWidth = strokeWidth;
        ctx.strokeStyle = color;
        ctx.fillStyle = color;
        ctx.lineJoin = "round";
        ctx.lineCap = "round";

        const w = width, h = height;
        const s = Math.min(w, h);
        // Work in a normalized box then scale.
        ctx.save();
        ctx.translate((w - s) / 2, (h - s) / 2);
        ctx.scale(s / 24, s / 24);

        switch (name) {
        case "bulb": {
            ctx.beginPath();
            ctx.arc(12, 9, 6, 0, Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(9, 17); ctx.lineTo(15, 17);
            ctx.moveTo(9.5, 19.5); ctx.lineTo(14.5, 19.5);
            ctx.stroke();
            break;
        }
        case "drop": {
            ctx.beginPath();
            ctx.moveTo(12, 3);
            ctx.bezierCurveTo(12, 3, 5, 11, 5, 15.5);
            ctx.arc(12, 15.5, 7, Math.PI, Math.PI * 2, true);
            ctx.bezierCurveTo(19, 11, 12, 3, 12, 3);
            ctx.closePath();
            ctx.stroke();
            break;
        }
        case "thermo": {
            ctx.beginPath();
            ctx.moveTo(10, 4);
            ctx.arc(12, 4, 2, Math.PI, 0);
            ctx.lineTo(14, 14.2);
            ctx.arc(12, 16.5, 3.2, -0.6, Math.PI + 0.6);
            ctx.lineTo(10, 4);
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(12, 16.5, 1.4, 0, Math.PI * 2);
            ctx.fill();
            break;
        }
        case "home": {
            ctx.beginPath();
            ctx.moveTo(4, 11);
            ctx.lineTo(12, 4);
            ctx.lineTo(20, 11);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(6, 10);
            ctx.lineTo(6, 20);
            ctx.lineTo(18, 20);
            ctx.lineTo(18, 10);
            ctx.stroke();
            break;
        }
        case "power": {
            ctx.beginPath();
            ctx.arc(12, 13, 7, -Math.PI / 2 + 0.6, -Math.PI / 2 - 0.6 + Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(12, 3); ctx.lineTo(12, 11);
            ctx.stroke();
            break;
        }
        case "leaf": {
            ctx.beginPath();
            ctx.moveTo(5, 19);
            ctx.bezierCurveTo(5, 9, 12, 5, 19, 5);
            ctx.bezierCurveTo(19, 15, 13, 19, 5, 19);
            ctx.closePath();
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(8, 16); ctx.lineTo(16, 8);
            ctx.stroke();
            break;
        }
        case "up": {
            ctx.beginPath();
            ctx.moveTo(6, 14); ctx.lineTo(12, 8); ctx.lineTo(18, 14);
            ctx.stroke();
            break;
        }
        case "down": {
            ctx.beginPath();
            ctx.moveTo(6, 10); ctx.lineTo(12, 16); ctx.lineTo(18, 10);
            ctx.stroke();
            break;
        }
        case "flat": {
            ctx.beginPath();
            ctx.moveTo(6, 12); ctx.lineTo(18, 12);
            ctx.stroke();
            break;
        }
        case "clock": {
            ctx.beginPath();
            ctx.arc(12, 12, 8, 0, Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(12, 7); ctx.lineTo(12, 12); ctx.lineTo(15.5, 14);
            ctx.stroke();
            break;
        }
        case "plus": {
            ctx.beginPath();
            ctx.moveTo(12, 5); ctx.lineTo(12, 19);
            ctx.moveTo(5, 12); ctx.lineTo(19, 12);
            ctx.stroke();
            break;
        }
        case "close": {
            ctx.beginPath();
            ctx.moveTo(7, 7); ctx.lineTo(17, 17);
            ctx.moveTo(17, 7); ctx.lineTo(7, 17);
            ctx.stroke();
            break;
        }
        }
        ctx.restore();
    }
}
