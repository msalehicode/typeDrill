import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
Page{
    anchors.fill: parent
    Rectangle
    {
        anchors.fill: parent
        color:"Grey"


        Column
        {
            id:idUrl
            width:parent.width
            height:200
            anchors.top: parent.top
            anchors.topMargin: 70
            spacing: 30
            Text
            {
                text:"api_url=";
                width:parent.width
                color:"blue"
                font.pixelSize: 20
            }
            TextInput
            {
                id:apiUrlText
                text:backend.getApiUrl();
                width:parent.width
                height:30
                color:"red"
                font.pixelSize: 15
            }
            Button
            {
                text:"update api_url"
                width:parent.width
                height:30
                onClicked:
                {
                    backend.setApiUrl(apiUrlText.text)
                }
            }
        }

        Rectangle
        {
            id:spacerRect
            color:"black"
            width:parent.width
            anchors.top:idUrl.bottom
            height:150;
        }

        Column
        {
            id:apikeyBase
            width:parent.width
            height:200
            anchors.top: spacerRect.bottom
            spacing:30
            Text
            {
                text:"api_key=";
                width:parent.width
                color:"blue"
                font.pixelSize: 20
            }
            TextInput
            {
                id:apiKeyText
                text:backend.getApiKey();
                width:parent.width
                height:30
                color:"red"
                font.pixelSize: 15
            }
            Button
            {
                text:"update api key"
                width:parent.width
                height:30
                onClicked:
                {
                    backend.setApiKey(apiKeyText.text)
                }
            }
        }

        Rectangle
        {
            id:spacerRect2
            color:"black"
            width:parent.width
            anchors.top:apikeyBase.bottom
            height:20;
        }

        Button
        {
            text:"pick android statusBar and NavigatorBar color"
            onClicked:
            {
                colorDialog.open()
            }
        }

        ColorDialog {
                id: colorDialog
                title: "Select Color"
                onAccepted: {
                    console.log("Picked color:", colorDialog.color)
                    spacerRect2.color = colorDialog.color
                    backend.setAndroidColors(colorDialog.color, colorDialog.color);
                }
            }



    }
}
