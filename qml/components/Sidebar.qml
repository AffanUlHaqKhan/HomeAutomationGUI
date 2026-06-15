import QtQuick
import HomeAuto

Rectangle {
    id: root
    property int currentIndex: 0

    width: 248
    color: Theme.sidebar

    Rectangle {
        anchors.right: parent.right
        width: 1; height: parent.height
        color: Theme.border
    }

    Column {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 8

        // Brand
        Row {
            spacing: 12
            bottomPadding: 18
            Rectangle {
                width: 40; height: 40; radius: 11
                gradient: Gradient {
                    GradientStop { position: 0; color: Theme.accent }
                    GradientStop { position: 1; color: Theme.violet }
                }
                AppIcon {
                    anchors.centerIn: parent
                    name: "home"; color: "white"
                    width: 22; height: 22; strokeWidth: 2.2
                }
            }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                Text {
                    text: "HomeAuto"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontH3
                    font.weight: Font.Bold
                }
                Text {
                    text: "Smart Control"
                    color: Theme.textFaint
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontTiny
                }
            }
        }

        Text {
            text: "CONTROL"
            color: Theme.textFaint
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontTiny
            font.weight: Font.Bold
            font.letterSpacing: 1.5
            bottomPadding: 4
        }

        Repeater {
            model: [
                { label: "Lighting",       icon: "bulb" },
                { label: "Watering",       icon: "drop" },
                { label: "Climate",        icon: "thermo" }
            ]
            NavButton {
                width: parent.width
                text: modelData.label
                iconName: modelData.icon
                selected: root.currentIndex === index
                onClicked: root.currentIndex = index
            }
        }

        Item { width: 1; height: 1 } // spacer pushes status to bottom via Column? use anchored instead
    }

    // System status pinned to bottom
    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 18
        spacing: 10

        Rectangle { width: parent.width; height: 1; color: Theme.border }

        Row {
            spacing: 10
            Rectangle {
                width: 9; height: 9; radius: 5
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.green
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 1100 }
                    NumberAnimation { to: 1.0; duration: 1100 }
                }
            }
            Column {
                Text {
                    text: "System Online"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                    font.weight: Font.DemiBold
                }
                Text {
                    text: "All hubs connected"
                    color: Theme.textFaint
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontTiny
                }
            }
        }
    }
}
