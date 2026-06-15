import QtQuick
import HomeAuto

Rectangle {
    id: root
    property bool hoverable: false
    property bool highlighted: false

    radius: Theme.radius
    color: highlighted ? Theme.cardHover : Theme.card
    border.width: 1
    border.color: highlighted ? Theme.accentSoft : Theme.border

    Behavior on color { ColorAnimation { duration: 140 } }
    Behavior on border.color { ColorAnimation { duration: 140 } }
}
