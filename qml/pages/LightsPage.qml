import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import HomeAuto

Item {
    id: page
    property RoomLightModel lights

    // Map warmth (0 warm .. 100 cool) to a light tint for the preview glow.
    function lightColor(warmth, brightness) {
        const warm = Qt.rgba(1.0, 0.72, 0.42, 1);
        const cool = Qt.rgba(0.81, 0.89, 1.0, 1);
        const t = warmth / 100;
        const c = Qt.rgba(
            warm.r + (cool.r - warm.r) * t,
            warm.g + (cool.g - warm.g) * t,
            warm.b + (cool.b - warm.b) * t, 1);
        return c;
    }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            width: page.width
            spacing: Theme.spacing

            // ---- Header ----
            PageHeader {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.pagePadding
                Layout.rightMargin: Theme.pagePadding
                Layout.topMargin: Theme.pagePadding
                title: "Lighting"
                subtitle: lights.onCount + " of " + lights.count + " rooms lit"

                PrimaryButton {
                    text: "All On"
                    iconName: "power"
                    outline: true
                    onClicked: lights.allOn()
                }
                PrimaryButton {
                    text: "All Off"
                    iconName: "power"
                    accentColor: Theme.red
                    onClicked: lights.allOff()
                }
                PrimaryButton {
                    text: "Add Zone"
                    iconName: "plus"
                    accentColor: Theme.teal
                    onClicked: addDialogLight.open()
                }
            }

            // ---- Summary pills ----
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.pagePadding
                Layout.rightMargin: Theme.pagePadding
                spacing: Theme.spacing
                StatPill {
                    label: "Active Lights"; iconName: "bulb"
                    value: lights.onCount + ""
                    accentColor: Theme.amber
                }
                StatPill {
                    label: "Avg Brightness"; iconName: "power"
                    value: lights.averageBrightness + "%"
                    accentColor: Theme.accent
                }
                StatPill {
                    label: "Total Rooms"; iconName: "home"
                    value: lights.count + ""
                    accentColor: Theme.teal
                }
                Item { Layout.fillWidth: true }
            }

            // ---- Room grid ----
            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.pagePadding
                Layout.rightMargin: Theme.pagePadding
                Layout.bottomMargin: Theme.pagePadding
                columns: Math.max(1, Math.floor((page.width - Theme.pagePadding * 2) / 320))
                rowSpacing: Theme.spacing
                columnSpacing: Theme.spacing

                Repeater {
                    model: lights
                    delegate: Card {
                        required property int index
                        required property string name
                        required property bool on
                        required property int brightness
                        required property int warmth

                        Layout.fillWidth: true
                        Layout.preferredHeight: 196
                        highlighted: on

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                Rectangle {
                                    width: 55; height: 45; radius: 12
                                    color: on ? Qt.alpha(page.lightColor(warmth, brightness), 0.22)
                                              : Theme.bgElevated
                                    AppIcon {
                                        anchors.centerIn: parent
                                        name: "bulb"
                                        width: 22; height: 22
                                        color: on ? page.lightColor(warmth, brightness)
                                                  : Theme.textFaint
                                        strokeWidth: 2.1
                                    }
                                }
                                Column {
                                    Layout.fillWidth: true
                                    Text {
                                        text: name
                                        color: Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontH3
                                        font.weight: Font.DemiBold
                                    }
                                    Text {
                                        text: on ? brightness + "% · " +
                                                   (warmth < 40 ? "Warm" : warmth < 70 ? "Neutral" : "Cool")
                                                 : "Off"
                                        color: on ? Theme.textMuted : Theme.textFaint
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSmall
                                    }
                                }
                                StyledSwitch {
                                    checked: on
                                    accentColor: Theme.amber
                                    onToggled: lights.setOn(index, checked)
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
                                        onClicked: lights.removeZone(index)
                                    }
                            }

                            Item { Layout.fillHeight: true }

                            // Brightness
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                opacity: on ? 1.0 : 0.4
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "Brightness"; color: Theme.textMuted
                                        font.family: Theme.fontFamily; font.pixelSize: Theme.fontTiny
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: brightness + "%"; color: Theme.text
                                        font.family: Theme.fontFamily; font.pixelSize: Theme.fontTiny
                                        font.weight: Font.DemiBold
                                    }
                                }
                                StyledSlider {
                                    Layout.fillWidth: true
                                    enabled: on
                                    from: 1; to: 100; value: brightness
                                    accentColor: Theme.amber
                                    onMoved: lights.setBrightness(index, Math.round(value))
                                }
                            }

                            // Warmth
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                opacity: on ? 1.0 : 0.4
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "Warm  →  Cool"; color: Theme.textMuted
                                        font.family: Theme.fontFamily; font.pixelSize: Theme.fontTiny
                                    }
                                }
                                StyledSlider {
                                    Layout.fillWidth: true
                                    enabled: on
                                    from: 0; to: 100; value: warmth
                                    accentColor: Theme.cyan
                                    onMoved: lights.setWarmth(index, Math.round(value))
                                }
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
                        lights.addZone(nameField.text);
                        addDialogLight.close();
                    }
                    onClicked: commit()
                }
            }
        }
    }
}
