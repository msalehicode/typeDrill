import QtQuick
import QtQuick.Controls

Item
{
    anchors.fill: parent
    Rectangle
    {
        anchors.fill: parent
        color:"green"

        Row
        {
            Button
            {
                text:"add word"
                onClicked:
                {
                    mainStackView.push("AddNewWordForm.qml")
                }
            }


            Button
            {
                text:"add table"
                onClicked:
                {
                    mainStackView.push("AddNewTableForm.qml")
                }
            }
        }

    }
}
