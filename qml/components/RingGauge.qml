import QtQuick
import HomeAuto

Item {
    id: root
    property real value: 0        // 0..100
    property color ringColor: Theme.accent
    property color trackColor: Theme.bgElevated
    property real thickness: 9
    property string centerText: Math.round(value) + "%"
    property string subText: ""

    implicitWidth: 120
    implicitHeight: 120

    onValueChanged: canvas.requestPaint()
    onRingColorChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const cx = width / 2, cy = height / 2;
            const r = Math.min(width, height) / 2 - root.thickness / 2 - 2;
            const start = -Math.PI / 2;
            const frac = Math.max(0, Math.min(1, root.value / 100));

            ctx.lineWidth = root.thickness;
            ctx.lineCap = "round";

            // Track
            ctx.beginPath();
            ctx.strokeStyle = root.trackColor;
            ctx.arc(cx, cy, r, 0, Math.PI * 2);
            ctx.stroke();

            // Value arc
            if (frac > 0.001) {
                ctx.beginPath();
                ctx.strokeStyle = root.ringColor;
                ctx.arc(cx, cy, r, start, start + frac * Math.PI * 2);
                ctx.stroke();
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 0
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.centerText
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontH2
            font.weight: Font.Bold
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.subText !== ""
            text: root.subText
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontTiny
        }
    }
}
