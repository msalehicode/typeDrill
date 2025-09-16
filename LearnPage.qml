import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    anchors.fill: parent

    // Define your ListModel here
    ListModel {
        id: lessonsModel
    }

    Rectangle {
        width: parent.width
        height: parent.height
        color: appColors.c_background

        // Static line rectangle (as per your original design)

        ListView {
            id: listView
            width: parent.width
            height: parent.height
            model: lessonsModel
            spacing: 25

            delegate: Item {
                width: 100
                height: 215
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: "grey"
                    anchors.centerIn: parent

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            console.log("clicked on lesson: ", model.l_id,
                                        " modeltitle:", model.l_title)
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        color: "black"
                        font.pixelSize: 18
                        text: model.l_title
                    }

                    Column {
                        anchors.top: parent.top
                        anchors.topMargin: 40
                        spacing: 10

                        Repeater {
                            model: 5
                            delegate: Rectangle {
                                width: 25
                                height: 25
                                radius: 25
                                color: "blue"
                            }
                        }
                    }
                }
            }
        }
    }

    // Connections for backend data
    Connections {
        target: backend
        function onLessonList(lessons) {
            // Clear the model and append new lessons data
            lessonsModel.clear();  // Clear the previous model data

            // If lessons exist, populate the model
            if (lessons && lessons.length > 0) {
                for (var i = 0; i < lessons.length; i++) {
                    lessonsModel.append({
                        l_id: lessons[i].id,
                        l_title: lessons[i].title,
                        l_level: String(lessons[i].level),
                        l_details: lessons[i].details,
                        l_text: lessons[i].text,
                        l_status: lessons[i].status
                    });
                }
            } else {
                console.log("No lessons available");
            }
        }
    }

    // Fetch the lessons when the component is completed
    Component.onCompleted: {
        backend.getLessonsList();  // This triggers the backend to fetch lessons
    }
}
