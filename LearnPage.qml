import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    anchors.fill: parent

    // Background for the page
    Rectangle {
        width: parent.width
        height: parent.height
        color: "#f4f4f4"  // Light gray background
        Rectangle {
            id:linerect
            width: 2
            height: 3000
            color: "#388E3C"
            anchors.horizontalCenter: parent.horizontalCenter  // Center the line
        }

        ScrollView
        {
                width: parent.width
                height: parent.height

                // Column inside the ScrollView to create a vertical list
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
                                radius: 20  // Circular shape
                                color: model.completed ? "#4CAF50" : "#D32F2F" // Green if completed, Red if not
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

                    // Repeater to generate a list of items
                    // Repeater {
                    //     model: 50  // Generate 50 items

                    //     delegate: Item {
                    //         width: parent.width
                    //         height: 50  // Height for each item

                    //         Rectangle {
                    //             width: parent.width
                    //             height: 50
                    //             color: index % 2 === 0 ? "lightblue" : "lightgreen"
                    //             border.color: "gray"

                    //             Text {
                    //                 anchors.centerIn: parent
                    //                 text: "Item " + (index + 1)
                    //                 color: "black"
                    //                 font.pixelSize: 20
                    //             }
                    //         }
                    //     }
                    // }
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
        // Main container for the roadmap
        /*Item {
            width: parent.width
            height: parent.height

            // Roadmap path (vertical progress line)
            Rectangle {
                // id:linerect
                width: 2
                height: 8000
                color: "#388E3C"
                anchors.horizontalCenter: parent.horizontalCenter  // Center the line
            }


            ScrollView {
                width:parent.width
                height: linerect.height  // Fill the available height
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                Column
                {
                    spacing:10
                    height:20*200
                    width:parent.width

                    // Add circle markers on the line
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
                                radius: 20  // Circular shape
                                color: model.completed ? "#4CAF50" : "#D32F2F" // Green if completed, Red if not
                                anchors.centerIn: parent

                                Text {
                                    anchors.centerIn: parent
                                    color: "black"
                                    font.pixelSize: 18
                                    text: model.lessonNumber
                                }
                                Column
                                {
                                    spacing:10
                                    Repeater
                                    {
                                        model: ListModel {
                                            ListElement { text:"h"}
                                            ListElement { text:"h"}
                                            ListElement { text:"h"}
                                            ListElement { text:"h"}
                                        }
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

            }

        }*/
    }
}
