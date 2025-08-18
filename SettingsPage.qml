import QtQuick
import QtQuick.Controls

Page{
    anchors.fill: parent
    Rectangle
    {
        anchors.fill: parent
        color:"Grey"


        Column
        {
            width:parent.width
            height:200
            anchors.top: parent.top
            anchors.topMargin: 70
            Text
            {
                text:"api_url=";
                width:parent.width
                height:100
                color:"blue"
                font.pixelSize: 20
            }
            TextInput
            {
                id:apiUrlText
                text:backend.whatIsApiUrl();
                width:parent.width
                height:100
                color:"red"
                font.pixelSize: 15
            }
            Button
            {
                text:"update api_url"
                width:parent.width
                height:100
                onClicked:
                {
                    backend.setApiUrl(apiUrlText.text)
                }
            }
        }
    }
}
