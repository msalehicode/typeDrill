import QtQuick
import QtQuick.Controls

Page
{
    width:parent.width
    height: parent.height
    Rectangle
    {
        anchors.fill: parent
        color:"green"

        Column
        {
            width:parent.width/2
            height:parent.height/2
            anchors.centerIn: parent
            spacing: 25
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

            Text
            {
                id:uploadResultText
                text:"upload result:"
                visible:false
                color:"blue"
                font.pixelSize: 15
                anchors.horizontalCenter: parent.horizontalCenter
            }


            Rectangle
            {
                width:parent.width
                height:300
                color:"purple"

                CustomComboboxWithIcon
                {
                    id: comboboxDatabases
                    anchors
                    {
                        right:parent.right
                        rightMargin:15
                        verticalCenter:parent.verticalCenter
                    }
                    onActivated: function(index)
                    {
                        currentIndex = index
                    }
                }

                CheckBox
                {
                    id:isitPublicCheckBox
                    checkState: "Unchecked"
                    text:"is it public?"
                }

                Button
                {
                    text:"upload database"
                    anchors.top:isitPublicCheckBox.bottom
                    onClicked:
                    {
                        var isItPublic = isitPublicCheckBox.checked ? "true" : "false"
                        uploadResultText.visible=true
                        var selectedDbName = comboboxDatabases.modelData[comboboxDatabases.currentIndex].text;
                        backend.uploadFileToApi(selectedDbName,isItPublic);
                    }
                }
            }
        }

    }


    function sqliteListToModel(sqliteList)
    {
        //get currentDatabase name
        var cDatabaseName = backend.whatIsCurrentDatabase();

        var model = [];
        for(var i = 0; i < sqliteList.length; i++)
        {
            if(sqliteList[i]===cDatabaseName)
                comboboxDatabases.currentIndex = i;

            model.push({
                           text: sqliteList[i],
                           icon: "resourses/streak.png" //dont want icon now
                       });
        }
        return model;
    }
    Connections
    {
        target:backend
        function onUploadDone(result)
        {
            uploadResultText.text = result;
        }
    }

    Component.onCompleted:
    {
        var files = backend.listOfDatabases();
        comboboxDatabases.modelData = sqliteListToModel(files);
    }
}
