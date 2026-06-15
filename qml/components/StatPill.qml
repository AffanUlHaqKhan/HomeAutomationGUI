import QtQuick
import HomeAuto

Rectangle {
    id: root
    property string label: ""
    property string value: ""
    property color accentColor: Theme.accent
    property string iconName: ""

    implicitWidth: row.implicitWidth + 28
    implicitHeight: 56
    radius: Theme.radiusSmall
    color: Theme.bgElevated
    border.width: 1
    border.color: Theme.border

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 12

        Rectangle {
            visible: root.iconName !== ""
            width: 34; height: 34; radius: 9
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.alpha(root.accentColor, 0.16)
            AppIcon {
                anchors.centerIn: parent
                name: root.iconName
                color: root.accentColor
                width: 18; height: 18
            }
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: root.value
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontH3
                font.weight: Font.Bold
            }
            Text {
                text: root.label
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontTiny
            }
        }
    }
}
