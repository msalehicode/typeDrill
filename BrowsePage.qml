import QtQuick
import QtQuick.Controls
import "CustomComponents"

Page
{
    header: Rectangle
    {
        width: parent.width
        height: 60
        color: appColors.c_headerBg
        Label
        {
            id:headerText
            text:"Browse Databases"
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

    Loader
    {
        id: theLoader
        anchors.fill: parent
    }

    Component
    {
        id: databasesListComponent
        Item
        {
            //true=visible ok button for popupmessage, false=visible cancel&Confirm buttons
            property bool visibleOKFlag: false
            onVisibleOKFlagChanged:
            {
                buttonOkPopup.setVisible=visibleOKFlag
                baseCofirmationButtons.visible=!visibleOKFlag
            }

            //because we want access to items from outside of component need to make them alis
            property alias urlModel: urlModel
            property alias listView: listView
            property alias buttonTryAgainList: buttonTryAgainList
            property alias textFetchListError: textFetchListError
            property alias popup: popupMessage


            Rectangle
            {
                color: appColors.c_background
                anchors.fill: parent

                CustomCombobox
                {
                    id: visibilityFilter
                    setBgColor: appColors.c_comboboxBgColor
                    setFontColor: appColors.c_buttonFontColor
                    setfontSize: appFontSizes.f_normal
                    setIconArrow: appIcons.icon_back_white
                    setWidth: parent.width
                    height:45
                    modelData: [{text:"community"},
                        {text:"all mine"}, {text:"my privates"},{ text:"my publics"},
                        {text: "officials"}]

                    setBgColorCurrentItem: appColors.c_comboboxBgColorCurrentItem
                    onActivated: function(index)
                    {
                        currentIndex = index
                        changeLoaderContent("list",currentItemText);
                        urlModel.clear()
                    }
                }


                ListView {
                    id: listView
                    anchors
                    {
                        top:visibilityFilter.bottom
                        topMargin:75
                        left:parent.left
                        right:parent.right
                        bottom:parent.bottom
                    }

                    model: urlModel //d_name, d_url, d_icon
                    visible: false
                    spacing: 15

                    delegate:Rectangle
                    {
                        width:parent.width/1.25
                        height:75
                        color:appColors.c_bgTableitem
                        radius: 15
                        clip:true
                        anchors
                        {
                            horizontalCenter: parent.horizontalCenter
                        }

                        Rectangle
                        {
                            id:baseIconTable
                            width:50
                            height:50
                            color:appColors.c_bgIcon_tableItem
                            border.color: appColors.c_borderColorIcon_tableItem
                            border.width: 1
                            radius:50
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            Image
                            {
                                source: model.d_icon ==="" ? appIcons.icon_question :  model.d_icon
                                width:45
                                height:45
                                anchors.centerIn: parent
                                onStatusChanged:
                                {
                                    if (status === Image.Error)
                                    {
                                        console.warn("Image failed to load:", source);
                                        source=appIcons.icon_question
                                    }
                                }
                            }
                        }

                        Rectangle
                        {
                            id:baseTableTitles
                            width:parent.width/1.70
                            height:parent.height/1.20
                            color:"transparent"
                            anchors.centerIn: parent
                            clip:true
                            Text
                            {
                                id:tableTitleText
                                text: model.d_name
                                color:appColors.c_fontcolor
                                font.pixelSize: appFontSizes.f_large
                                font.bold:true
                                anchors.centerIn: parent
                            }


                            Row
                            {
                                anchors.top:tableTitleText.bottom
                                width: parent.width
                                height:15
                                Label
                                {
                                    text:"id:"+model.d_id
                                    color:appColors.c_fontcolor
                                }
                                Label
                                {
                                    text:(visibilityFilter.currentItemText==="community"||visibilityFilter.currentItemText==="officials")
                                         ? " by: "+model.d_owner : " by you"
                                    color:appColors.c_fontcolor
                                }
                                Image
                                {
                                    width:15
                                    height:15
                                    source: model.d_visibility==="public"? appIcons.icon_eye : appIcons.icon_hide
                                }
                            }
                        }

                        MouseArea {
                            id:mAreaItem
                            anchors.fill: parent
                            onPressAndHold:
                            {

                                //add items into the menu
                                if(visibilityFilter.currentItemText==="all mine" ||
                                   visibilityFilter.currentItemText==="my privates" ||
                                   visibilityFilter.currentItemText==="my publics")
                                {
                                    popupMenu.openWhereOnClicked(mAreaItem,listView)

                                    popupMenu.addItem("Delete",model.d_name,model.d_id,"delete",appIcons.icon_delete);
                                    popupMenu.addItem("Rename",model.d_name,model.d_id,"rename",appIcons.icon_delete);
                                    if(model.d_visibility==="private")
                                        popupMenu.addItem("Change Visibility to public",model.d_name,model.d_id,"public",appIcons.icon_eye);
                                    else
                                        popupMenu.addItem("Change Visibility to private",model.d_name,model.d_id,"private",appIcons.icon_hide);
                                }
                            }
                        }


                        //download is upper than menu
                        Row
                        {
                            width: 100
                            height:parent.height
                            anchors
                            {
                                right:parent.right
                                rightMargin:20
                                verticalCenter:parent.verticalCenter
                            }

                            CustomButtonWithIcon
                            {
                                id:downloadButton
                                setWidth:35
                                setHeight:35
                                setButtonText:"";
                                setButtonBorderColor: "transparent";
                                setButtonFontColor:appColors.c_fontcolor;
                                setButtonBackColor:appColors.c_buttonBgColor
                                setTextMagin: 5
                                setIconHeight: 25
                                setIconWidth: 25
                                setIconSource:  appIcons.icon_download_white
                                anchors
                                {
                                    verticalCenter:parent.verticalCenter
                                    right:parent.right
                                    rightMargin:10
                                }

                                onButtonClicked:
                                {
                                    changeLoaderContent("download")
                                    backend.download(model.d_url,model.d_name);
                                }
                            }
                        }



                    }//end of the item

                }

                ListModel {
                    id: urlModel
                }


                /*because popup is heavy to load, and this fetch list error
                  would call popup.open too early, need another way to show user error
                  and make him be able try again to fetch list
                  by using A text and button on center.
                */

                Text
                {
                    id:textFetchListError
                    text:"Loading List..."
                    visible: false
                    color: appColors.c_fontcolor
                    font.pixelSize: appFontSizes.f_title
                    wrapMode: Text.WordWrap
                    width:parent.width/2
                    height:implicitHeight
                    anchors
                    {
                        centerIn:parent
                    }
                }

                CustomButton
                {
                    id:buttonTryAgainList
                    setButtonText:"Try Again..";
                    setVisible: false
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setBold: true
                    setButtonFontsize: appFontSizes.f_buttonFontSize
                    setButtonsBorderWidth: 0
                    setRadius: 20
                    setWidth: 70
                    setHeight:50
                    anchors
                    {
                        top:textFetchListError.bottom
                        topMargin:15
                        horizontalCenter:parent.horizontalCenter
                    }

                    onButtonClicked:
                    {
                        changeLoaderContent("list",visibilityFilter.currentItemText)
                    }
                }

                CustomPopupMenu
                {
                    id:popupMenu
                    setWidth:parent.width/1.10
                    setBgColor: appColors.c_background
                    setFontColor:appColors.c_fontcolor
                    setBgItemColor: appColors.c_comboboxBgColor
                    setFontSize: appFontSizes.f_normal
                    onItemClicked: function(tid,iaction,ttext)
                    {
                        // console.log("onItme clicked: tid=",tid, " iaction=",iaction, "ttext=",ttext)
                        var result;
                        switch(iaction)
                        {
                            case "rename":
                            {
                                buttonConfirmPopupMessageRename.setActionHandler( function()
                                {
                                    backend.renameApiDbFile(tid,newNameTable.theText);
                                    popupMessageRename.close()
                                });
                                newNameTable.theText=ttext;
                                popupMessageRename.open()
                            }break;

                            case "delete":
                            {
                                buttonConfirmPopupMessage.setActionHandler(function()
                                {
                                    backend.deleteApiDbFile(tid);
                                    popupMessage.close()
                                });
                                popupMessage.open("Are you sure to delete file: " + ttext + " ?");
                            }break;
                            case "public":
                            {
                                buttonConfirmPopupMessage.setActionHandler(function()
                                {
                                    backend.changeApiDbFileVisiblity(tid,"public");
                                    popupMessage.close()
                                });
                                popupMessage.open("Are you sure to change visibility to public file: " + ttext + " ?");
                            }break;

                            case "private":
                            {
                                buttonConfirmPopupMessage.setActionHandler(function()
                                {
                                    backend.changeApiDbFileVisiblity(tid,"private");
                                    popupMessage.close()
                                });
                                popupMessage.open("Are you sure to change visibility to private file: " + ttext + " ?");
                            }break;
                        }
                        popupMenu.close()
                    }

                }//end of menu
                CustomPopupMessage
                {
                    id:popupMessage
                    setDefaultText: ""
                    setFailColor: appColors.c_bgPopupContentFailed
                    setSuccessColor:appColors.c_bgPopupContentSuccess
                    setBgContent: appColors.c_bgPopupContentDefault
                    setTextFontSize: appFontSizes.f_normal
                    setTextColor:  appColors.c_fontcolor
                    setBgColorPopup: appColors.c_background
                    setWidth: parent.width/1.50
                    setHeight: 250

                    CustomButton
                    {
                        id:buttonOkPopup
                        setButtonText:"Ok got it";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setBold: true
                        setVisible: false
                        setButtonFontsize: appFontSizes.f_buttonFontSize
                        setButtonsBorderWidth: 0
                        setRadius: 20
                        setWidth: 70
                        setHeight:50
                        anchors
                        {
                            bottom:parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        onButtonClicked:
                        {
                            visibleOKFlag=false;
                            popupMessage.close()
                            changeLoaderContent("list",visibilityFilter.currentItemText);
                        }
                    }

                    Row
                    {
                        id:baseCofirmationButtons
                        visible: true
                        width:70*2+10
                        height:50
                        spacing:10
                        anchors
                        {
                            bottom:parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        CustomButton
                        {
                            id:buttonCancelPopupMessage
                            setButtonText:"Cancel";
                            setButtonBorderColor:appColors.c_buttonBorderColor
                            setButtonBackColor: appColors.c_buttonCancelBgColor
                            setButtonFontColor: appColors.c_buttonCancelFontColor
                            setBold: true
                            setButtonFontsize: appFontSizes.f_buttonFontSize
                            setButtonsBorderWidth: 0
                            setRadius: 20
                            setWidth: 70
                            setHeight:50
                            onButtonClicked:
                            {
                                popupMessage.close()
                            }
                        }
                        CustomButton
                        {
                            id:buttonConfirmPopupMessage
                            setButtonText:"Confirm";
                            setButtonBorderColor:appColors.c_buttonBorderColor
                            setButtonBackColor: appColors.c_buttonBgColor
                            setButtonFontColor: appColors.c_buttonFontColor
                            setBold: true
                            setButtonFontsize: appFontSizes.f_buttonFontSize
                            setButtonsBorderWidth: 0
                            setRadius: 20
                            setWidth: 70
                            setHeight:50
                            //actions will handle dynamically for each item by passing function to setActionHandler()
                        }

                    }


                }




                CustomPopupMessage
                {
                    id:popupMessageRename
                    setDefaultText: ""
                    setFailColor: appColors.c_bgPopupContentFailed
                    setSuccessColor:appColors.c_bgPopupContentSuccess
                    setBgContent: appColors.c_bgPopupContentDefault
                    setTextFontSize: appFontSizes.f_normal
                    setTextColor:  appColors.c_fontcolor
                    setBgColorPopup: appColors.c_background
                    setWidth: parent.width/1.50
                    setHeight: 250

                    CustomTextInput
                    {
                        id:newNameTable
                        setWidth: parent.width/1.25
                        setHeight: 50
                        setBgColor: appColors.c_bgColor_textinput
                        setBordercolor: appColors.c_borderColor_textinput
                        setBorderWidth:2
                        setFontSize:appFontSizes.f_textInput
                        setFontColor: appColors.c_fontColor_textinput
                        setRadius:10
                        theText:""
                        setErrorPosfix: ""
                        setErrorPrefix: ""
                        setTitleText:"New Table Name:"
                        anchors
                        {
                            centerIn:parent
                        }
                        onTheTextAccepted:
                        {
                            buttonConfirmPopupMessageRename.runActionHandler()
                        }
                    }



                    Row
                    {
                        width:parent.width/2
                        height:50
                        spacing: 7
                        anchors
                        {
                            horizontalCenter:parent.horizontalCenter
                            bottom:parent.bottom
                        }

                        CustomButton
                        {
                            id:buttonCancelPopupMessageRename
                            setButtonText:"Cancel";
                            setButtonBorderColor:appColors.c_buttonBorderColor
                            setButtonBackColor: appColors.c_buttonCancelBgColor
                            setButtonFontColor: appColors.c_buttonCancelFontColor
                            setBold: true
                            setButtonFontsize: appFontSizes.f_buttonFontSize
                            setButtonsBorderWidth: 0
                            setRadius: 20
                            setWidth: 70
                            setHeight:50
                            onButtonClicked:
                            {
                                popupMessageRename.close()
                            }
                        }


                        CustomButton
                        {
                            id:buttonConfirmPopupMessageRename
                            setButtonText:"Rename";
                            setButtonBorderColor:appColors.c_buttonBorderColor
                            setButtonBackColor: appColors.c_buttonBgColor
                            setButtonFontColor: appColors.c_buttonFontColor
                            setBold: true
                            setButtonFontsize: appFontSizes.f_buttonFontSize
                            setButtonsBorderWidth: 0
                            setRadius: 20
                            setWidth: 70
                            setHeight:50
                            //actions will handle dynamically for each item by passing function to setActionHandler()
                        }

                    }

                }

            }

        }

    }


    Component
    {
        id: downloadFileComponent
        Item
        {
            //because we want access to items from outside of component need to make them alis
            property alias proccessBar: proccessBar
            property alias popup: popup
            Rectangle
            {
                color:appColors.c_background
                anchors
                {
                    top:parent.top
                    left:parent.left
                    right:parent.right
                    bottom:parent.bottom
                }

                CustomProccessBar
                {
                    id:proccessBar
                    currentValue:0
                    totalValue: 100
                    setWidth: parent.width/2
                    setHeight: 20
                    setSpacing:1
                    setSeperatorWord:"%"
                    setStatusTotalValueText:false
                    setFontColor: appColors.c_fontcolor
                    setBgColor: appColors.c_bg_tableList
                    setFontSize: appFontSizes.f_normal
                    setProgressColor: appColors.c_buttonBgColor
                    setCotinainerRadius: parent.width
                    anchors
                    {
                        horizontalCenter: parent.horizontalCenter
                        top:parent.top
                        // topMargin: appKeyboardVisible ? appKeyboardHeight : 15
                        topMargin:15
                    }
                }


                CustomButton
                {
                    id:buttonCancelDownload
                    setButtonText:"Cancel";
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setBold: true
                    setButtonFontsize: appFontSizes.f_buttonFontSize
                    setButtonsBorderWidth: 0
                    setRadius: 20
                    setWidth: 70
                    setHeight:50
                    anchors.centerIn: parent
                    onButtonClicked:
                    {
                        changeLoaderContent("list")
                    }
                }


                CustomPopupMessage
                {
                    id: popup
                    setDefaultText: "please wait..."
                    setFailColor: appColors.c_bgPopupContentFailed
                    setSuccessColor:appColors.c_bgPopupContentSuccess
                    setBgContent: appColors.c_bgPopupContentDefault
                    setTextFontSize: appFontSizes.f_normal
                    setTextColor:  appColors.c_fontcolor
                    setBgColorPopup: appColors.c_background
                    setWidth: parent.width/1.50
                    setHeight: 200
                    onPopUpClosed:
                    {
                        //reset text after close and hide button
                        // setDefaultText= "please wait..."
                        buttonOkPopup.setVisible=false

                        changeLoaderContent("list")
                    }
                    onPopUpStatusChanged:
                    {
                        //show button
                        buttonOkPopup.setVisible=true
                    }

                    CustomButton
                    {
                        id:buttonOkPopup
                        setButtonText:"Ok got it";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setBold: true
                        setVisible: false
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
            }

        }



    }



    function changeLoaderContent(target="list",filter="community")
    {
        if(target==="list")
        {
            appBlockBackButton=false
            theLoader.sourceComponent=databasesListComponent
            backend.fetchUrlList(filter);

            //sometimes after emit FetchUrlList the server/backend doesn't emit result(onUrlListFailed/onUrlListReady)
            //so need to make sure user have way to be able try again
            theLoader.item.textFetchListError.visible=true
            theLoader.item.buttonTryAgainList.setVisible=true
        }
        else
        {
            appBlockBackButton=true
            theLoader.sourceComponent=downloadFileComponent
        }
    }


    function handleUrlListReady(list)
    {
        if (theLoader.item && theLoader.item.urlModel)
        {
            theLoader.item.urlModel.clear()
            if(list.length<=0)
            {
                theLoader.item.buttonTryAgainList.setVisible=true
                theLoader.item.textFetchListError.visible=true
                theLoader.item.listView.visible=false
                theLoader.item.textFetchListError.text= "there is no file check somewhere else.";
            }
            else
            {
                //hide try again text and button and show list
                theLoader.item.buttonTryAgainList.setVisible=false
                theLoader.item.textFetchListError.visible=false
                theLoader.item.listView.visible=true

                for (var i = 0; i < list.length; i++) {
                    // console.log("Model item", list[i].d_name, list[i].d_icon, list[i].d_url);
                    // Append an object with name, url, and icon properties
                    // console.log("Item:", JSON.stringify(list[i]));

                    theLoader.item.urlModel.append({
                                                       d_id: list[i].d_id,
                                                       d_name: list[i].d_name,
                                                       d_url: list[i].d_url,
                                                       d_icon: list[i].d_icon,
                                                       d_visibility: list[i].d_visibility,
                                                       d_owner: list[i].d_owner
                                                   });
                }

            }


        }
        else
            console.warn("urlModel is not available yet")

    }

    function handleUrlListFailed(errorString)
    {
        console.log("Failed to fetch URL list:", errorString)
        theLoader.item.textFetchListError.text= "Failed to fetch URL list:"+errorString


        //because fetchlist is first thing on page so
        //this may cause always popup not avaible..
        //so use a button on center to user be able try again..
        /*if (theLoader.item && theLoader.item.popup)
        {
            theLoader.item.popup.open()
            var re = "Failed to fetch URL list:" + errorString;
            theLoader.item.popup.setResult(re, "0")
        }
        else {
            console.warn("popup is not available yet")
        }*/

    }

    function handleDownloadFinished(success,filePath)
    {
        if (success)
        {
            console.log("Downloaded to:", filePath)
            if (theLoader.item && theLoader.item.popup)
            {
                theLoader.item.popup.open("please wait...")
                theLoader.item.popup.setResult("download successed","1")
                appBlockBackButton=false
            }
            else
                console.warn("popup is not available yet")


        }
        else
        {
            console.log("Download failed")
            if (theLoader.item && theLoader.item.popup)
            {
                theLoader.item.popup.open("please wait...")
                theLoader.item.popup.setResult("download failed","0")
            }
            else
                console.warn("popup is not available yet")
        }


    }

    function handleDownloadProgress(bytesReceived,bytesTotal)
    {
        if (bytesTotal > 0)
        {
            theLoader.item.proccessBar.currentValue = (bytesReceived / bytesTotal) * 100
        }
    }

    function showResult(result)
    {
        // if (theLoader.item && theLoader.item.popupMessage)
        {
            theLoader.item.popup.open("please wait...")

            //hide confimation buttons and just show ok button
            theLoader.item.visibleOKFlag=true
            switch(result)
            {
                case "File removed successfully":
                case "File renamed successfully":
                case "File visibility updated":
                case "File renamed successfully":
                    theLoader.item.popup.setResult(result,"1")
                    break;

                default:  theLoader.item.popup.setResult(result,"0")
                    break;
            }
        }
        // else
            // console.log("item is not ready")
    }

    Connections
    {
        target: backend

        //couldnt access to the elemnts inside compoent so the way was to call js function..
        //to pass data to js function need to make function(para)
        onUrlListFailed: function (errorString)
        {
            handleUrlListFailed(errorString)
        }
        onUrlListReady: function(list)
        {
            handleUrlListReady(list)
        }
        onDownloadProgress: function(bytesReceived, bytesTotal)
        {
            handleDownloadProgress(bytesReceived,bytesTotal)
        }
        onDownloadFinished: function(success, filePath)
        {
            handleDownloadFinished(success, filePath)
        }

        onDeleteApiDbFileResult: function (result)
        {
            showResult(result);
        }
        onRenameApiDbFileResult: function(result)
        {
            showResult(result);
        }
        onChangeApiDbFileVisiblityResult: function (result)
        {
            showResult(result);
        }

    }

    Component.onCompleted:
    {
        changeLoaderContent("list")//,visibilityFilter.currentItemText);
    }
}
