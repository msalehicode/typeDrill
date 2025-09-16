import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    anchors.fill: parent


    Rectangle {
        width: parent.width
        height: parent.height
        color: "#f4f4f4"
        Rectangle {
            id:linerect
            width: 2
            height: 3000
            color: "#388E3C"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        ScrollView
        {
                width: parent.width
                height: parent.height

                Column {
                    width: parent.width
                    spacing: 10
                    Repeater {
                        model: ListModel {
                            ListElement { lessonNumber: "1"; completed: true }
                            ListElement { lessonNumber: "2"; completed: true }
                            ListElement { lessonNumber: "3"; completed: false }
                            ListElement { lessonNumber: "4"; completed: false }
                            ListElement { lessonNumber: "5"; completed: false }
                            ListElement { lessonNumber: "5"; completed: false }
                            ListElement { lessonNumber: "5"; completed: false }
                            ListElement { lessonNumber: "5"; completed: false }
                            ListElement { lessonNumber: "5"; completed: false }
                            ListElement { lessonNumber: "5"; completed: false }
                            ListElement { lessonNumber: "5"; completed: false }

                        }

                        delegate: Item {
                            width: parent.width
                            height: 215

                            // Rectangle for circle
                            Rectangle {
                                width: 40
                                height: 40
                                radius: 20
                                color: model.completed ? "#4CAF50" : "#D32F2F"
                                anchors.centerIn: parent

                                MouseArea
                                {
                                    anchors.fill: parent
                                    onClicked:
                                    {
                                        console.log("clicked on lesson: ",model.lessonNumber)
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    color: "black"
                                    font.pixelSize: 18
                                    text: model.lessonNumber
                                }
                                Column
                                {
                                    anchors.top: parent.top
                                    anchors.topMargin: 40
                                    spacing:10
                                    Repeater
                                    {
                                        model: 5
                                        delegate: Rectangle {
                                            width: 25
                                            height: 25
                                            radius: 25
                                            color:"blue"
                                        }

                                    }
                                }
                            }
                        }
                    }
                }
                // MouseArea {
                //     id: scrollAreaMouseArea
                //     anchors.fill: parent
                //     drag.target: parent

                //     onReleased: {
                //         parent.contentItem.forceActiveFocus()
                //     }
                // }
            }

    }
}
