import QtQuick
import QtQuick.Controls
import "CustomComponents"

Page
{
    width:parent.width
    height: parent.height
    Rectangle
    {
        anchors.fill: parent
        color:appColors.c_background
        Rectangle
        {
            color:"transparent"
            width:parent.width/1.10
            height:parent.height/1.50
            anchors.centerIn: parent

            Column
            {
                width:parent.width
                height:parent.height
                spacing:5
                Row
                {
                    width:parent.width
                    height:100
                    // anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 35
                    CustomButtonWithIcon
                    {
                        setWidth:80
                        setHeight:80
                        setButtonText:"Add Word";
                        setButtonFontColor:appColors.c_fontcolor
                        setButtonBackColor:"transparent"
                        setTextMagin: 5
                        setIconHeight: 50
                        setIconWidth: 50
                        setButtonsBorderWidth:2
                        setButtonBorderColor:appColors.c_fontcolor
                        setIconSource:  appIcons.icon_settings
                        onButtonClicked:
                        {
                            mainStackView.push("./forms/AddNewWordForm.qml")
                        }
                    }


                    CustomButtonWithIcon
                    {
                        setWidth:80
                        setHeight:80
                        setButtonText:"New Table";
                        setButtonFontColor:appColors.c_fontcolor
                        setButtonBackColor:"transparent"
                        setTextMagin: 5
                        setIconHeight: 50
                        setIconWidth: 50
                        setButtonsBorderWidth:2
                        setButtonBorderColor:appColors.c_fontcolor
                        setIconSource:  appIcons.icon_browse
                        onButtonClicked:
                        {
                            mainStackView.push("./forms/AddNewTableForm.qml")
                        }
                    }

                    CustomButtonWithIcon
                    {
                        setWidth:80
                        setHeight:80
                        setButtonText:"New Database";
                        setButtonFontColor:appColors.c_fontcolor
                        setButtonBackColor:"transparent"
                        setTextMagin: 5
                        setIconHeight: 50
                        setIconWidth: 50
                        setButtonsBorderWidth:2
                        setButtonBorderColor:appColors.c_fontcolor
                        setIconSource:  appIcons.icon_settings
                        onButtonClicked:
                        {
                            mainStackView.push("./forms/AddNewDatabaseForm.qml")
                        }
                    }


                    CustomButtonWithIcon
                    {
                        setWidth:80
                        setHeight:80
                        setButtonText:"delete Database";
                        setButtonFontColor:appColors.c_fontcolor
                        setButtonBackColor:"transparent"
                        setTextMagin: 5
                        setIconHeight: 50
                        setIconWidth: 50
                        setButtonsBorderWidth:2
                        setButtonBorderColor:appColors.c_fontcolor
                        setIconSource:  appIcons.icon_delete
                        onButtonClicked:
                        {
                            mainStackView.push("./forms/RemoveDatabaseForm.qml")
                        }
                    }

                }


                Rectangle
                {
                    color:"transparent"
                    width:parent.width/1.50
                    height:250
                    border.width: 2
                    radius:20
                    border.color: appColors.c_fontcolor
                    anchors.horizontalCenter: parent.horizontalCenter
                    clip:true
                    Column
                    {
                        width:parent.width
                        height:parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 25

                        CheckBox
                        {
                            id:isitPublicCheckBox
                            checkState: "Unchecked"
                            text:"is it public?"
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        CustomComboboxWithIcon
                        {
                            id: comboboxDatabases
                            anchors.horizontalCenter: parent.horizontalCenter
                            setBgColor: appColors.c_comboboxBgColor
                            setFontColor: appColors.c_buttonFontColor
                            setBgColorCurrentItem: appColors.c_comboboxBgColorCurrentItem
                            setIconArrow: appIcons.icon_back_white
                            setfontSize: appFontSizes.f_normal
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
                            id:buttonSubmitSearch
                            setButtonText:"upload";
                            setButtonBorderColor:appColors.c_buttonBorderColor
                            setButtonBackColor: appColors.c_buttonBgColor
                            setButtonFontColor: appColors.c_buttonFontColor
                            setBold: true
                            setButtonFontsize: appFontSizes.f_buttonFontSize
                            setButtonsBorderWidth: 0
                            setRadius: 20
                            setWidth: 70
                            setHeight:50
                            anchors.horizontalCenter: parent.horizontalCenter
                            onButtonClicked:
                            {
                                appBlockBackButton=true
                                popup.open()
                                var isItPublic = isitPublicCheckBox.checked ? "true" : "false"
                                var selectedDbName = comboboxDatabases.modelData[comboboxDatabases.currentIndex].text;
                                backend.uploadFileToApi(selectedDbName,isItPublic);
                            }
                        }
                    }


                }


            }



        }


    }

    CustomPopupMessage
    {
        id: popup
        setDefaultText: "uploading... wait..."
        setBtnText: "Ok"
        setFailColor: appColors.c_bgPopupContentFailed
        setSuccessColor:appColors.c_bgPopupContentSuccess
        setBgContent: appColors.c_bgPopupContentDefault
        setTextFontSize: appFontSizes.f_normal
        setTextColor:  appColors.c_fontcolor
        setBgColorPopup: appColors.c_background
        setBgButton: appColors.c_buttonBgColor
        setBordercolorButton: appColors.c_buttonBorderColor
    }

    function refresh()
    {
        console.log("Manage Words/tables/databases is refreshing!");


        //get currentDatabase name and fetch and set available databases
        var cDatabaseName = backend.whatIsCurrentDatabase();
        var filesNames = backend.listOfDatabases();
        comboboxDatabases.modelData = sqliteListToModel(filesNames,cDatabaseName);
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
        target:backend
        function onUploadDone(result)
        {
            if(result==="Upload succeeded.")
            {
                popup.setResult(result,"1")
            }
            else
            {
                popup.setResult(result,"0")
            }
            appBlockBackButton=false
        }
    }

    Component.onCompleted:
    {
        refresh()
    }
}
