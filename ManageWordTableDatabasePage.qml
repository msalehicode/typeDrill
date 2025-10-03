import QtQuick
import QtQuick.Controls
import "CustomComponents"

Page
{
    header: Rectangle
    {
        id:headerPage
        width: parent.width
        height: 60
        color: appColors.c_headerBg
        Label
        {
            id:headerText
            text:"Manage Databases/Tables"
            horizontalAlignment: Text.AlignHCenter
            color: appColors.c_fontcolor
            font.pixelSize: appFontSizes.f_normal
            font.bold:true
            anchors
            {
                verticalCenter:parent.verticalCenter
                left:parent.left
                leftMargin: 50
            }
        }
    }

    CustomTimer //to make countdown when during download something happend user can try or cancel
    {
        id:downloadUploadTimer
        onEachTrigger:
        {
            if(secondsPassed>15)
            {
                baseCancelTryAgainButtons.visible=true
            }
        }
        onWhenStoppped:
        {
            baseCancelTryAgainButtons.visible=false
        }
    }


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
                spacing:10
                CustomCollapsiblePanel
                {
                    id:tableCollaps
                    setTitle: "Table"
                    setWidth: parent.width/1.50
                    anchors.horizontalCenter: parent.horizontalCenter
                    setHeight:50
                    setBgColorButton: appColors.c_comboboxBgColor
                    setTextColor: appColors.c_buttonFontColor
                    setTextFontSize: appFontSizes.f_normal
                    setIconArrow: appIcons.icon_back_white
                    setBgContent:appColors.c_collapsContentBgColor
                    setContentHeight:120
                    setOpen:false


                    onCollapsed:
                    {
                        if(setOpen)
                            setHeight = setHeight+setContentHeight
                        else
                            setHeight=50
                    }

                    Row
                    {
                        width: parent.width
                        height:80
                        spacing:50
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
                            setButtonsBorderWidth:0
                            setButtonBorderColor: "transparent"
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
                            setButtonsBorderWidth:0
                            setButtonBorderColor: "transparent"
                            setIconSource:  appIcons.icon_browse
                            onButtonClicked:
                            {
                                mainStackView.push("./forms/AddNewTableForm.qml")
                            }
                        }
                    }
                }

                CustomCollapsiblePanel
                {
                    id:databaseCollaps
                    setTitle: "Database"
                    setWidth: parent.width/1.50
                    anchors.horizontalCenter: parent.horizontalCenter
                    setHeight:50
                    setBgColorButton: appColors.c_comboboxBgColor
                    setTextColor: appColors.c_buttonFontColor
                    setTextFontSize: appFontSizes.f_normal
                    setIconArrow: appIcons.icon_back_white
                    setBgContent:appColors.c_collapsContentBgColor
                    setContentHeight:120
                    setOpen: false

                    onCollapsed:
                    {
                        if(setOpen)
                            setHeight = setHeight+setContentHeight
                        else
                            setHeight=50
                    }

                    Row
                    {
                        width: parent.width
                        height:80
                        spacing:50
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
                            setButtonsBorderWidth:0
                            setButtonBorderColor:"transparent"
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
                            setButtonsBorderWidth:0
                            setButtonBorderColor:"transparent"
                            setIconSource:  appIcons.icon_delete
                            onButtonClicked:
                            {
                                mainStackView.push("./forms/RemoveDatabaseForm.qml")
                            }
                        }

                    }

                }


                CustomCollapsiblePanel
                {
                    id:uploadCollaps
                    setTitle: "Upload"
                    setWidth: parent.width/1.50
                    anchors.horizontalCenter: parent.horizontalCenter
                    setHeight:50
                    setBgColorButton: appColors.c_comboboxBgColor
                    setTextColor: appColors.c_buttonFontColor
                    setTextFontSize: appFontSizes.f_normal
                    setIconArrow: appIcons.icon_back_white
                    setBgContent:appColors.c_collapsContentBgColor
                    setContentHeight:300
                    setOpen: false

                    onCollapsed:
                    {
                        if(setOpen)
                            setHeight = setHeight+setContentHeight
                        else
                            setHeight=50
                    }

                    Column
                    {
                        width:parent.width
                        height:parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10
                        CustomCheckBox
                        {
                            id:isitPublicCheckBox
                            setWidth: parent.width/2
                            setHeight: 50
                            setBoxCheckedBorderColor:appColors.c_buttonBgColor
                            setBoxUncheckedBorderColor:appColors.c_buttonBgColor
                            setBoxCheckedBackColor:appColors.c_buttonBgColor
                            setCheckBoxFontColor:appColors.c_fontcolor
                            setCheckBoxFontsize:appFontSizes.f_normal
                            setBold:true
                            setWidthBox:25
                            setHeightBox: 25
                            setCheckBoxText:"Is it public?"
                            setBoxBorderWidth:3
                            anchors.horizontalCenter: parent.horizontalCenter
                            setBoxIconSource: appIcons.icon_check
                            setStatus: true
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

                        Row
                        {
                            width:parent.width/2
                            height:50
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing:5
                            CustomButtonWithIcon
                            {
                                id:buttonUpload
                                setButtonText:"Upload";
                                setButtonBorderColor:appColors.c_buttonBorderColor
                                setButtonBackColor: appColors.c_buttonBgColor
                                setButtonFontColor: appColors.c_fontcolor
                                setIconSource: appIcons.icon_upload_white
                                setTextMagin:10
                                setIconWidth: 30
                                setIconHeight: 30
                                setButtonsBorderWidth: 0
                                setRadius: 50
                                setWidth: 50
                                setHeight:50
                                anchors.verticalCenter: parent.verticalCenter
                                onButtonClicked:
                                {
                                    blockFlowBack(true)
                                    buttonTryAgainPopup.setActionHandler(function()
                                    {
                                        buttonUpload.buttonClicked()
                                    });
                                    popup.open("uploading.. please wait..")
                                    var isItPublic = isitPublicCheckBox.setStatus ? "true" : "false"
                                    var selectedDbName = comboboxDatabases.modelData[comboboxDatabases.currentIndex].text;
                                    backend.uploadFileToApi(selectedDbName,isItPublic);
                                }
                            }

                            CustomButtonWithIcon
                            {
                                id:buttonUpdate
                                setButtonText:"Update";
                                setButtonBorderColor:appColors.c_buttonBorderColor
                                setButtonBackColor: appColors.c_buttonBgColor
                                setButtonFontColor: appColors.c_fontcolor
                                setIconSource: appIcons.icon_question
                                setIconWidth: 30
                                setIconHeight: 30
                                setButtonsBorderWidth: 0
                                setTextMagin:10
                                setRadius: 50
                                setWidth: 50
                                setHeight:50
                                anchors.verticalCenter: parent.verticalCenter
                                onButtonClicked:
                                {
                                    blockFlowBack(true)
                                    buttonTryAgainPopup.setActionHandler(function()
                                    {
                                        buttonUpdate.buttonClicked()
                                    });
                                    popup.open("updating.. please wait..")
                                    var selectedDbName = comboboxDatabases.modelData[comboboxDatabases.currentIndex].text;
                                    backend.overwriteFileToApi(selectedDbName);
                                }
                            }

                            CustomButtonWithIcon
                            {
                                id:buttonSync
                                setButtonText:"Sync";
                                setButtonBorderColor:appColors.c_buttonBorderColor
                                setButtonBackColor: appColors.c_buttonBgColor
                                setButtonFontColor: appColors.c_fontcolor
                                setIconSource: appIcons.icon_turn_white
                                setIconWidth: 30
                                setIconHeight: 30
                                setTextMagin:10
                                setButtonsBorderWidth: 0
                                setRadius: 50
                                setWidth: 50
                                setHeight:50
                                anchors.verticalCenter: parent.verticalCenter
                                onButtonClicked:
                                {
                                    blockFlowBack(true)
                                    buttonTryAgainPopup.setActionHandler(function()
                                    {
                                        buttonSync.buttonClicked()
                                    });
                                    popup.open("syncing.. please wait..")
                                    var selectedDbName = comboboxDatabases.modelData[comboboxDatabases.currentIndex].text;
                                    backend.syncDatabaseWithApi(selectedDbName);
                                }
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
        setFailColor: appColors.c_bgPopupContentFailed
        setSuccessColor:appColors.c_bgPopupContentSuccess
        setBgContent: appColors.c_bgPopupContentDefault
        setTextFontSize: appFontSizes.f_normal
        setTextColor:  appColors.c_fontcolor
        setBgColorPopup: appColors.c_background
        setWidth: parent.width/1.50
        setHeight: 250
        onPopUpClosed:
        {
            //reset value and status upload and hide button
            // setDefaultText= "uploading... wait..."
            buttonClosePopup.setVisible=false
        }
        onPopUpStatusChanged:
        {
            //show button
            buttonClosePopup.setVisible=true
        }


        Row
        {
            id:baseCancelTryAgainButtons
            visible: false
            width: 145
            height:50
            spacing:5
            anchors
            {
                bottom:parent.bottom
                horizontalCenter:parent.horizontalCenter
            }

            CustomButton
            {
                id:buttonCancelPopup
                setButtonText:"Cancel";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonCancelBgColor
                setButtonFontColor: appColors.c_buttonCancelFontColor
                setVisible: true
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 70
                setHeight:50
                onButtonClicked:
                {
                    blockFlowBack(false)
                    popup.close()
                }
            }
            CustomButton
            {
                id:buttonTryAgainPopup
                setButtonText:"Try Again";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setVisible: true
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 70
                setHeight:50
            }
        }

        CustomButton
        {
            id:buttonClosePopup
            setButtonText:"Ok got it";
            setButtonBorderColor:appColors.c_buttonBorderColor
            setButtonBackColor: appColors.c_buttonBgColor
            setButtonFontColor: appColors.c_buttonFontColor
            setVisible: false
            setBold: true
            setButtonFontsize: appFontSizes.f_buttonFontSize
            setButtonsBorderWidth: 0
            setRadius: 20
            setWidth: 70
            setHeight:50
            anchors
            {
                bottom:parent.bottom
                horizontalCenter:parent.horizontalCenter
            }
            onButtonClicked:
            {
                popup.close()
            }
        }
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

    function getFilenameFromUrl(url) {
      // Create a URL object to parse it easily
      try {
        let urlObj = new URL(url);
        let pathname = urlObj.pathname; // e.g. "/some/path/file.txt"
        // Get the last part after the last slash
        let filename = pathname.substring(pathname.lastIndexOf('/') + 1);
        return filename;
      } catch (e) {
        // If url is not valid URL (e.g. just a path), fallback to string manipulation
        let filename = url.substring(url.lastIndexOf('/') + 1);
        return filename;
      }
    }


    function blockFlowBack(status)
    {
        if(status)
        {
            appBlockBackButton=true
            headerPage.visible=false
            appVisibleBackOrMenuButton=false
            downloadUploadTimer.startTimer()
        }
        else
        {
            appBlockBackButton=false
            headerPage.visible=true
            appVisibleBackOrMenuButton=true
            downloadUploadTimer.stopTimer()
        }
    }

    Connections
    {
        target:backend
        function onUploadDone(result)
        {
            let syncSeparator = "download and replace to sync:";


            if(result==="File uploaded successfully"
                    || result==="File updated successfully"
                    || result.includes("synchronized successfully"))
            {
                popup.setResult(result,"1")
                blockFlowBack(false)

            }
            else if(result.includes(syncSeparator))
            {
                let parts = result.split(syncSeparator);
                let downloadUrl = parts[1].trim();
                let fileName = getFilenameFromUrl(downloadUrl);
                backend.download(downloadUrl,fileName,true);
            }
            else
            {
                popup.setResult(result,"0")
                blockFlowBack(false)
            }

        }

        function onDownloadFinished(success, filePath)
        {
            popup.setResult("synchronized successfully (downloaded)","1")
            blockFlowBack(false)
        }
    }

    Component.onCompleted:
    {
        refresh()
    }
}
