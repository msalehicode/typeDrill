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
            //because we want access to items from outside of component need to make them alis
            property alias urlModel: urlModel
            property alias listView: listView
            property alias buttonTryAgainList: buttonTryAgainList
            property alias textFetchListError: textFetchListError

            Rectangle
            {
                color: appColors.c_background
                anchors
                {
                    top:parent.top
                    left:parent.left
                    right:parent.right
                    bottom:parent.bottom
                }


                ListView {
                    id: listView
                    anchors
                    {
                        top:parent.top
                        topMargin:25
                        left:parent.left
                        right:parent.right
                        bottom:parent.bottom
                    }

                    model: urlModel //d_name, d_url, d_icon
                    visible: false
                    spacing: 15

                    delegate:Rectangle
                    {
                        width:parent.width/1.50
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
                        }


                        Rectangle
                        {
                            width:35
                            height:35
                            color:appColors.c_buttonBgColor
                            radius:50
                            // rotation: 180
                            anchors
                            {
                                right:parent.right
                                rightMargin:20
                                verticalCenter:parent.verticalCenter
                            }
                            Image
                            {
                                source: appIcons.icon_download
                                width:parent.width/1.50
                                height:parent.height/1.50
                                anchors.centerIn: parent
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked:
                            {

                                changeLoaderContent("download")
                                backend.download(model.d_url,model.d_name);
                            }
                        }

                    }

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
                    height:200
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
                        changeLoaderContent("list")
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


    function changeLoaderContent(target="list")
    {
        if(target==="list")
        {
            appBlockBackButton=false
            theLoader.sourceComponent=databasesListComponent
            backend.fetchUrlList()

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
            theLoader.item.buttonTryAgainList.setVisible=false
            theLoader.item.textFetchListError.visible=false
            theLoader.item.listView.visible=true


            theLoader.item.urlModel.clear()
            for (var i = 0; i < list.length; i++) {
                // console.log("Model item", list[i].d_name, list[i].d_icon, list[i].d_url);
                // Append an object with name, url, and icon properties
                theLoader.item.urlModel.append({
                                                   d_name: list[i].d_name,
                                                   d_url: list[i].d_url,
                                                   d_icon: list[i].d_icon
                                               });
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
    }

    Component.onCompleted:
    {
        changeLoaderContent("list")
    }
}
