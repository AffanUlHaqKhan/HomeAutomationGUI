import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import HomeAuto

Item {
    id: page
    property WateringZoneModel zones

    function fmtRemaining(sec) {
        if (sec <= 0) return "—";
        const m = Math.floor(sec / 60);
        const s = sec % 60;
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
    }

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
                title: "Watering"
                subtitle: zones.activeCount > 0
                          ? zones.activeCount + " zone" + (zones.activeCount > 1 ? "s" : "") + " irrigating now"
                          : "All zones idle"

                PrimaryButton {
                    text: "Add Zone"
                    iconName: "plus"
                    accentColor: Theme.teal
                    onClicked: addDialog.open()
                }
                PrimaryButton {
                    text: "Stop All"
                    iconName: "power"
                    accentColor: Theme.red
                    outline: true
                    enabled: zones.activeCount > 0
                    onClicked: zones.stopAll()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.pagePadding
                Layout.rightMargin: Theme.pagePadding
                spacing: Theme.spacing
                StatPill {
                    label: "Watering Now"; iconName: "drop"
                    value: zones.activeCount + ""
                    accentColor: Theme.cyan
                }
                StatPill {
                    label: "Avg Soil Moisture"; iconName: "leaf"
                    value: zones.averageMoisture + "%"
                    accentColor: Theme.teal
                }
                StatPill {
                    label: "Total Zones"; iconName: "home"
                    value: zones.count + ""
                    accentColor: Theme.accent
                }
                Item { Layout.fillWidth: true }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Theme.pagePadding
                Layout.rightMargin: Theme.pagePadding
                Layout.bottomMargin: Theme.pagePadding
                columns: Math.max(1, Math.floor((page.width - Theme.pagePadding * 2) / 360))
                rowSpacing: Theme.spacing
                columnSpacing: Theme.spacing

                Repeater {
                    model: zones
                    delegate: Card {
                        required property int index
                        required property string name
                        required property int moisture
                        required property bool watering
                        required property bool autoMode
                        required property int duration
                        required property int remaining
                        required property string flow

                        Layout.fillWidth: true
                        Layout.preferredHeight: 260
                        highlighted: watering

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 18
                            spacing: 16

                            // Moisture ring
                            ColumnLayout {
                                spacing: 8
                                RingGauge {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 112; height: 112
                                    value: moisture
                                    ringColor: Theme.moistureColor(moisture)
                                    centerText: moisture + "%"
                                    subText: "moisture"
                                }
                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    radius: 6
                                    color: watering ? Qt.alpha(Theme.cyan, 0.18)
                                                    : Qt.alpha(Theme.textFaint, 0.14)
                                    implicitWidth: statusRow.implicitWidth + 18
                                    implicitHeight: 24
                                    Row {
                                        id: statusRow
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Rectangle {
                                            width: 7; height: 7; radius: 4
                                            anchors.verticalCenter: parent.verticalCenter
                                            color: watering ? Theme.cyan : Theme.textFaint
                                        }
                                        Text {
                                            text: watering ? "Watering" : "Idle"
                                            color: watering ? Theme.cyan : Theme.textMuted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontTiny
                                            font.weight: Font.DemiBold
                                        }
                                    }
                                }
                            }

                            // Controls
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: name
                                        color: Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontH3
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
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
                                        onClicked: zones.removeZone(index)
                                    }
                                }

                                // Auto toggle row
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    Text {
                                        text: "Auto schedule"
                                        color: Theme.textMuted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSmall
                                    }
                                    Item { Layout.fillWidth: true }
                                    StyledSwitch {
                                        checked: autoMode
                                        accentColor: Theme.teal
                                        onToggled: zones.setAuto(index, checked)
                                    }
                                }

                                // Duration
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "Duration"; color: Theme.textMuted
                                        font.family: Theme.fontFamily; font.pixelSize: Theme.fontTiny
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: duration + " min"; color: Theme.text
                                        font.family: Theme.fontFamily; font.pixelSize: Theme.fontTiny
                                        font.weight: Font.DemiBold
                                    }
                                }
                                StyledSlider {
                                    Layout.fillWidth: true
                                    from: 1; to: 30; value: duration
                                    accentColor: Theme.cyan
                                    onMoved: zones.setDuration(index, Math.round(value))
                                }

                                Item { Layout.fillHeight: true }

                                // Live run info
                                RowLayout {
                                    Layout.fillWidth: true
                                    visible: watering
                                    spacing: 14
                                    Column {
                                        Text {
                                            text: page.fmtRemaining(remaining)
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontBody
                                            font.weight: Font.Bold
                                        }
                                        Text {
                                            text: "remaining"; color: Theme.textFaint
                                            font.family: Theme.fontFamily; font.pixelSize: Theme.fontTiny
                                        }
                                    }
                                    Column {
                                        Text {
                                            text: flow + " L/m"
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontBody
                                            font.weight: Font.Bold
                                        }
                                        Text {
                                            text: "flow rate"; color: Theme.textFaint
                                            font.family: Theme.fontFamily; font.pixelSize: Theme.fontTiny
                                        }
                                    }
                                }

                                PrimaryButton {
                                    Layout.fillWidth: true
                                    text: watering ? "Stop Watering" : "Water Now"
                                    iconName: "drop"
                                    accentColor: watering ? Theme.red : Theme.cyan
                                    outline: watering
                                    onClicked: watering ? zones.stop(index) : zones.start(index)
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
        id: addDialog
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
                text: "Add Watering Zone"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontH3
                font.weight: Font.Bold
            }
            Text {
                text: "Name the new irrigation zone."
                color: Theme.textMuted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSmall
            }

            TextField {
                id: nameField
                Layout.fillWidth: true
                placeholderText: "e.g. Side Garden"
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
                    onClicked: addDialog.close()
                }
                PrimaryButton {
                    id: addAction
                    text: "Add Zone"
                    iconName: "plus"
                    accentColor: Theme.teal
                    function commit() {
                        zones.addZone(nameField.text);
                        addDialog.close();
                    }
                    onClicked: commit()
                }
            }
        }
    }
}
