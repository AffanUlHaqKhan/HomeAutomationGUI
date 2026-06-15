import QtQuick
import QtQuick.Controls.Basic
import HomeAuto

AbstractButton {
    id: root
    property string iconName: "home"
    property bool selected: false

    implicitHeight: 48
    padding: 12

    background: Rectangle {
        radius: Theme.radiusSmall
        color: root.selected ? Theme.accentSoft
             : root.hovered  ? Theme.cardHover
             : "transparent"
        Behavior on color { ColorAnimation { duration: 130 } }

        Rectangle {
            width: 3; radius: 2
            height: parent.height - 16
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: -6
            color: Theme.accent
            visible: root.selected
        }
    }

    contentItem: Row {
        spacing: 14
        leftPadding: 4
        AppIcon {
            name: root.iconName
            width: 22; height: 22
            anchors.verticalCenter: parent.verticalCenter
            color: root.selected ? Theme.text : Theme.textMuted
            strokeWidth: root.selected ? 2.2 : 1.9
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root.selected ? Theme.text : Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            font.weight: root.selected ? Font.DemiBold : Font.Medium
        }
    }
}
