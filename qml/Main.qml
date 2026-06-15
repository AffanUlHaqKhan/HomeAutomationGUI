import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import HomeAuto

ApplicationWindow {
    id: window
    width: 1280
    height: 820
    minimumWidth: 1040
    minimumHeight: 680
    visible: true
    title: "HomeAuto — Smart Home Control"
    color: Theme.bg

    // Shared backend models (single instances for the whole app).
    RoomLightModel    { id: lightModel }
    WateringZoneModel { id: wateringModel }
    ClimateModel      { id: climateModel }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Sidebar {
            id: sidebar
            Layout.fillHeight: true
            currentIndex: (typeof startTab !== 'undefined') ? startTab : 0
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Top bar
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 64
                color: Theme.bgElevated
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width; height: 1
                    color: Theme.border
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.pagePadding
                    anchors.verticalCenter: parent.verticalCenter
                    text: ["Lighting", "Watering", "Climate"][sidebar.currentIndex]
                          + " Control"
                    color: Theme.textMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                }

                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.pagePadding
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 16

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.right: parent.right
                            text: clock.timeText
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontH3
                            font.weight: Font.DemiBold
                        }
                        Text {
                            anchors.right: parent.right
                            text: clock.dateText
                            color: Theme.textFaint
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontTiny
                        }
                    }

                    Rectangle {
                        width: 40; height: 40; radius: 20
                        anchors.verticalCenter: parent.verticalCenter
                        gradient: Gradient {
                            GradientStop { position: 0; color: Theme.teal }
                            GradientStop { position: 1; color: Theme.accent }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "AK"
                            color: "white"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                            font.weight: Font.Bold
                        }
                    }
                }

                QtObject {
                    id: clock
                    property string timeText: ""
                    property string dateText: ""
                }
                Timer {
                    interval: 1000; running: true; repeat: true; triggeredOnStart: true
                    onTriggered: {
                        const d = new Date();
                        clock.timeText = Qt.formatTime(d, "hh:mm");
                        clock.dateText = Qt.formatDate(d, "ddd, MMM d");
                    }
                }
            }

            // Page area
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: sidebar.currentIndex

                LightsPage   { lights: lightModel }
                WateringPage { zones: wateringModel }
                ClimatePage  { rooms: climateModel }
            }
        }
    }
}
