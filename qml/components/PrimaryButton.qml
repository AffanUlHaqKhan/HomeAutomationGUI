import QtQuick
import QtQuick.Controls.Basic
import HomeAuto

Button {
    id: root
    property color accentColor: Theme.accent
    property bool outline: false
    property string iconName: ""

    implicitHeight: 38
    leftPadding: 16; rightPadding: 16

    contentItem: Row {
        spacing: 8
        AppIcon {
            visible: root.iconName !== ""
            name: root.iconName
            anchors.verticalCenter: parent.verticalCenter
            width: 17; height: 17
            color: root.outline ? root.accentColor : "white"
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root.outline ? root.accentColor : "white"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSmall
            font.weight: Font.DemiBold
        }
    }

    background: Rectangle {
        radius: Theme.radiusSmall
        color: root.outline
               ? (root.hovered ? Qt.alpha(root.accentColor, 0.14) : "transparent")
               : (root.down ? Qt.darker(root.accentColor, 1.2)
                            : root.hovered ? Qt.lighter(root.accentColor, 1.12)
                                           : root.accentColor)
        border.width: root.outline ? 1.4 : 0
        border.color: root.accentColor
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}
