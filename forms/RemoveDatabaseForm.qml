import QtQuick
import QtQuick.Controls
import "../CustomComponents"


Page
{
    id:removeDatabaseFrom
    anchors.fill: parent
    Rectangle
    {
        anchors.fill: parent
        color:appColors.c_background


        Rectangle
        {
            color:"transparent"
            width:parent.width/1.50
            height:parent.height/2
            anchors.centerIn: parent
            Column
            {
                width: parent.width
                height: parent.height
                spacing:15

                CustomComboboxWithIcon
                {
                    id: comboboxDatabases
                    anchors.horizontalCenter: parent.horizontalCenter
                    setBgColor: appColors.c_comboboxBgColor
                    setFontColor: appColors.c_buttonFontColor
                    setBgColorCurrentItem: appColors.c_comboboxBgColorCurrentItem
                    setfontSize: appFontSizes.f_normal
                    setIconArrow: appIcons.icon_back_white
                    setRadius: 10
                    setWidth: 180
                    setHeight: 50
                    onActivated: function(index)
                    {
                        currentIndex = index
                    }
                }


                CustomButton
                {
                    setButtonText:"delete";
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setBold: true
                    setButtonFontsize: appFontSizes.f_buttonFontSize
                    setButtonsBorderWidth: 0
                    setRadius: 20
                    setWidth: 100
                    setHeight: 50
                    // anchors.verticalCenter:parent.verticalCenter
                    onButtonClicked:
                    {
                        console.log("comboboxDatabases.currentItemText",comboboxDatabases.currentItemText)
                        backend.removeDatabase(comboboxDatabases.currentItemText);
                    }
                }

            }
        }
    }

    function sqliteListToModel(sqliteList,currentDatabaseName="")
    {
        var model = [];
        for(var i = 0; i < sqliteList.length; i++)
        {
            if(sqliteList[i]===currentDatabaseName)
                comboboxDatabases.currentIndex = i;

            model.push({
                           text: sqliteList[i],
                           icon: appIcons.icon_question //dont want icon now
                       });
        }
        return model;
    }

    Connections
    {
        target: backend
        function onDatabaseRemoveResult(result)
        {
            if (result)
                mainStackView.pop();
            else
                console.log("error while remove database...")
        }
    }

    Component.onCompleted:
    {
        var cDatabaseName = backend.whatIsCurrentDatabase();
        var filesNames = backend.listOfDatabases();
        comboboxDatabases.modelData = sqliteListToModel(filesNames,cDatabaseName);
    }
}

