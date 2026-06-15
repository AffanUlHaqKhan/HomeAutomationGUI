import QtQuick
import QtQuick.Controls.Basic
import HomeAuto

Slider {
    id: control
    property color accentColor: Theme.accent
    implicitHeight: 26

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: 6
        radius: 3
        color: Theme.bgElevated

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: 3
            color: control.accentColor
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: 18; height: 18; radius: 9
        color: "white"
        border.width: 3
        border.color: control.accentColor
        scale: control.pressed ? 1.15 : 1.0
        Behavior on scale { NumberAnimation { duration: 90 } }
    }
}
