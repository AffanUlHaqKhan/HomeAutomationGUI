import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import HomeAuto

Item {
    id: page
    property ClimateModel rooms

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: page.width
            spacing: Theme.spacing

            PageHeader {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.pagePadding
                Layout.rightMargin: Theme.pagePadding
                Layout.topMargin: Theme.pagePadding
                title: "Climate"
                subtitle: "Live temperature & humidity across " + rooms.count + " rooms"

                PrimaryButton {
                    text: "Add Zone"
                    iconName: "plus"
                    accentColor: Theme.teal
                    onClicked: addDialogLight.open()
                }

            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.pagePadding
                Layout.rightMargin: Theme.pagePadding
                spacing: Theme.spacing
                StatPill {
                    label: "Average Temp"; iconName: "thermo"
                    value: rooms.avgTemperature + "°C"
                    accentColor: Theme.amber
                }
                StatPill {
                    label: "Average Humidity"; iconName: "drop"
                    value: rooms.avgHumidity + "%"
                    accentColor: Theme.cyan
                }
                Item { Layout.fillWidth: true }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.pagePadding
                Layout.rightMargin: Theme.pagePadding
                Layout.bottomMargin: Theme.pagePadding
                columns: Math.max(1, Math.floor((page.width - Theme.pagePadding * 2) / 380))
                rowSpacing: Theme.spacing
                columnSpacing: Theme.spacing

                Repeater {
                    model: rooms
                    delegate: Card {
                        required property int index
                        required property string name
                        required property string temperature
                        required property int humidity
                        required property var tempHistory
                        required property var humHistory
                        required property string tempMin
                        required property string tempMax
                        required property int trend

                        Layout.fillWidth: true
                        Layout.preferredHeight: 250

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: name
                                    color: Theme.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontH3
                                    font.weight: Font.DemiBold
                                }
                                Item { Layout.fillWidth: true }
                                Rectangle {
                                    width: 26; height: 26; radius: 8
                                    color: Theme.bgElevated
                                    AppIcon {
                                        anchors.centerIn: parent
                                        name: trend > 0 ? "up" : trend < 0 ? "down" : "flat"
                                        width: 16; height: 16
                                        color: trend > 0 ? Theme.red
                                             : trend < 0 ? Theme.cyan : Theme.textMuted
                                    }
                                }

                                // Remove zone
                                    AbstractButton {
                                        id: removeBtn
                                        implicitWidth: 28; implicitHeight: 28
                                        ToolTip.text: "Remove zone"
                                        ToolTip.visible: hovered
                                        ToolTip.delay: 500
                                        background: Rectangle {
                                            radius: 8
                                            color: removeBtn.hovered ? Qt.alpha(Theme.red, 0.16)
                                                                      : Theme.bgElevated
                                            Behavior on color { ColorAnimation { duration: 120 } }
                                        }
                                        contentItem: AppIcon {
                                            name: "close"
                                            anchors.centerIn: parent
                                            width: 15; height: 15
                                            color: removeBtn.hovered ? Theme.red : Theme.textMuted
                                        }
                                        onClicked: rooms.removeZone(index)
                                    }
                            }

                            // Big readouts
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 24
                                Row {
                                    spacing: 8
                                    AppIcon {
                                        name: "thermo"; width: 26; height: 26
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: Theme.tempColor(parseFloat(temperature))
                                    }
                                    Column {
                                        Text {
                                            text: temperature + "°"
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontHuge
                                            font.weight: Font.Bold
                                        }
                                        Text {
                                            text: "temperature"
                                            color: Theme.textFaint
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontTiny
                                        }
                                    }
                                }
                                Row {
                                    spacing: 8
                                    AppIcon {
                                        name: "drop"; width: 26; height: 26
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: Theme.cyan
                                    }
                                    Column {
                                        Text {
                                            text: humidity + "%"
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontHuge
                                            font.weight: Font.Bold
                                        }
                                        Text {
                                            text: "humidity"
                                            color: Theme.textFaint
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontTiny
                                        }
                                    }
                                }
                                Item { Layout.fillWidth: true }
                            }

                            Item { Layout.fillHeight: true }

                            // Trend chart
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Temperature trend"
                                    color: Theme.textMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontTiny
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "L " + tempMin + "°  ·  H " + tempMax + "°"
                                    color: Theme.textFaint
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontTiny
                                }
                            }
                            Sparkline {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 56
                                values: tempHistory
                                lineColor: Theme.tempColor(parseFloat(temperature))
                            }
                        }
                    }
                }
            }
        }
    }

    // ---- Add Zone dialog ----
    Popup {
        id: addDialogLight
        anchors.centerIn: parent
        width: 380
        modal: true
        focus: true
        padding: 22
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        onOpened: { nameField.text = ""; nameField.forceActiveFocus(); }

        background: Rectangle {
            radius: Theme.radius
            color: Theme.card
            border.width: 1
            border.color: Theme.border
        }

        contentItem: ColumnLayout {
            spacing: 16

            Text {
                text: "Add Light Zone"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontH3
                font.weight: Font.Bold
            }
            Text {
                text: "Name the new light zone."
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }

            TextField {
                id: nameField
                Layout.fillWidth: true
                placeholderText: "e.g. Bedroom Main Garden"
                color: Theme.text
                placeholderTextColor: Theme.textFaint
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                selectByMouse: true
                leftPadding: 12; rightPadding: 12; topPadding: 9; bottomPadding: 9
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: Theme.bgElevated
                    border.width: 1.4
                    border.color: nameField.activeFocus ? Theme.teal : Theme.border
                }
                onAccepted: addAction.commit()
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Item { Layout.fillWidth: true }
                PrimaryButton {
                    text: "Cancel"
                    outline: true
                    accentColor: Theme.textMuted
                    onClicked: addDialogLight.close()
                }
                PrimaryButton {
                    id: addAction
                    text: "Add Zone"
                    iconName: "plus"
                    accentColor: Theme.teal
                    function commit() {
                        rooms.addZone(nameField.text);
                        addDialogLight.close();
                    }
                    onClicked: commit()
                }
            }
        }
    }
}
