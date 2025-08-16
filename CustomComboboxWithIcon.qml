import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    width: 150
    height: 50
    anchors.right: parent.right

    property var modelData: [
        { text: "Apple", icon: "resourses/streak.png" },
        { text: "Banana", icon: "resourses/check.png" },
        { text: "Cherry", icon: "resourses/streak.png" }
    ]
    property int currentIndex: 0
    signal activated(int index)

    Rectangle {
        id: baseCombobox
        anchors.fill: parent
        color: "black"

        RowLayout {
            anchors.fill: parent
            spacing: 5

            Image {
                source: modelData[currentIndex].icon
                width: 24
                height: 24
                fillMode: Image.PreserveAspectFit
                Layout.alignment: Qt.AlignVCenter
                anchors.right: parent.right
            }

            Text {
                text: modelData[currentIndex].text
                color: "white"
                font.pixelSize: 16
                Layout.alignment: Qt.AlignVCenter
                anchors.left: parent.left
                anchors.leftMargin:15
            }

            Item { Layout.fillWidth: true } // Spacer
        }

        MouseArea {
            anchors.fill: parent
            onClicked: popup.open()
        }
    }

    Popup {
        id: popup
        x: baseCombobox.x
        y: baseCombobox.y + baseCombobox.height
        width: baseCombobox.width
        height: Math.min(modelData.length * 50, 300) // max height
        modal: true
        focus: true

        background: Rectangle {
            color: "transparent"
        }

        Rectangle
        {
            width: baseCombobox.width
            color:"black"
            height: Math.min(modelData.length * 50, 300) // max height
            ListView {
                anchors.fill: parent
                model: modelData
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                anchors.margins: 2


                delegate: Rectangle {
                    width: parent.width
                    height: 50
                    color: index === currentIndex ? "#555" : "#333"
                    // border.color: "white"
                    // border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        spacing: 5
                        anchors.margins: 5

                        Image {
                            source: modelData.icon
                            width: 24
                            height: 24
                            fillMode: Image.PreserveAspectFit
                            Layout.alignment: Qt.AlignVCenter
                            anchors.right: parent.right
                        }

                        Text {
                            text: modelData.text
                            color: "white"
                            font.pixelSize: 16
                            Layout.alignment: Qt.AlignVCenter
                            anchors.left: parent.left
                            anchors.leftMargin:15
                        }

                        Item { Layout.fillWidth: true }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            activated(index)
                            popup.close()
                        }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

        }


    }




}
