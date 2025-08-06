import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
Page
{
    id:homePage
    anchors.fill: parent
    Rectangle
    {
        anchors.fill: parent;
        color:"#222424"
        Row
        {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            Button{
                text:"practice"
                onClicked:
                {
                    mainStackView.push("PickTablePage.qml",  { routeTarget: "PracticePage.qml"})
                }
            }
            Button{
                text:"practice verb"
                onClicked:
                {
                    mainStackView.push("PickTablePage.qml",  { routeTarget: "PracticeVerbs.qml"})
                }
            }
            Button{
                text:"add word"
                onClicked:
                {
                    mainStackView.push("PickTablePage.qml",  { routeTarget: "AddNewWordForm.qml"})
                }
            }

            Button{
                text:"add table"
                onClicked:
                {
                    // mainStackView.push("AddNewTableForm.qml", { myMessage: "Hello from Page1!" })
                    mainStackView.push("AddNewTableForm.qml")
                }
            }
        }

    }

}
