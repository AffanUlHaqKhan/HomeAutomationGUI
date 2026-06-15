import QtQuick
import HomeAuto

Item {
    id: root
    property string title: ""
    property string subtitle: ""
    default property alias actions: actionRow.data

    implicitHeight: 56

    Column {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3
        Text {
            text: root.title
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontH1
            font.weight: Font.Bold
        }
        Text {
            text: root.subtitle
            color: Theme.textMuted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSmall
        }
    }

    Row {
        id: actionRow
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
    }
}
