import QtQuick
import QtQuick.Controls.Basic
import HomeAuto

Switch {
    id: control
    property color accentColor: Theme.accent

    // Tightly sized to the indicator so it never overflows a layout cell.
    padding: 0
    spacing: 0
    implicitWidth: 46
    implicitHeight: 26

    indicator: Rectangle {
        implicitWidth: 46
        implicitHeight: 26
        radius: 13
        color: control.checked ? control.accentColor : Theme.bgElevated
        border.width: control.checked ? 0 : 1.4
        border.color: Theme.border
        Behavior on color { ColorAnimation { duration: 150 } }

        Rectangle {
            x: control.checked ? parent.width - width - 3 : 3
            anchors.verticalCenter: parent.verticalCenter
            width: 20; height: 20; radius: 10
            color: "white"
            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }
    }

    contentItem: Item {} // label handled externally for layout flexibility
}
