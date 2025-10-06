import QtQuick
import QtQuick.Controls
import "../CustomComponents"
import QtQuick.Dialogs
import QtMultimedia

Page
{
    id:addNewWordForm
    property var parentName: someObject

    //data order passed by QML to backend
    //word: text, meaning, example, translate, source, status, picture, audio
    property var wordTitles: ["text", "meaning", "example", "translate", "source","status"]

    property string contentPath;

    //fill from outside
    property string formType: "none"
    property int wordId: -1
    property var formData : ["data1","data2","data3","data4","data5","data6"]


    property var wordStatuses: [{text:"0"},{ text:"starred"}, {text:"archived"}]

    property bool pictureChanged : false;
    property bool removePicture: false;

    property bool audioChanged : false;
    property bool removeAudio: false;

    property string selectedImagePath : ""
    property string selectedAudioPath : ""


    property var fileDialogFilters : ["Images (*.png *.jpg *.jpeg *.bmp *.gif)",
                                      "Audio (*.wav *.mp3 *.ogg *.flac *.m4a *.aiff)"]

    property bool fileDialogPickingImage: true
    onFileDialogPickingImageChanged:
    {
        if(fileDialogPickingImage)
        {
            fileDialog.nameFilters = fileDialogFilters[0]
        }
        else
        {
            fileDialog.nameFilters = fileDialogFilters[1]
        }
    }

    header: Rectangle
    {
        width: parent.width
        height: 60
        color: appColors.c_headerBg
        Label
        {
            id:headerText
            text:"Modify Word"
            horizontalAlignment: Text.AlignHCenter
            color: appColors.c_fontcolor
            font.pixelSize: appFontSizes.f_normal
            font.bold:true
            anchors
            {
                verticalCenter:parent.verticalCenter
                left:parent.left
                leftMargin: 25
            }
        }
    }


    ListModel
    {
        id: titleModel
    }

    SoundEffect
    {
        id: audio
        volume: 1.0
        onStatusChanged:
        {
            if (audio.status === SoundEffect.Ready)
            {
                playButton.setVisible=true
            }
        }
    }



    FileDialog
    {
        id: fileDialog
        title: "Select a File"
        onAccepted:
        {
            var theFile;
            var decodedFilePath;
            if(fileDialogPickingImage)
            {
                pictureChanged = true
                removePictureButton.setVisible=true
                selectedImagePath = fileDialog.selectedFile.toString()
                picture.source = selectedImagePath

                //if picture is animated one play it
                picture.playing = selectedImagePath.toString().split('.').pop().toLowerCase()==="gif"? true : false


                // URL-decode the file path to handle any encoded characters (e.g., %3A for colon)
                // decodedFilePath = decodeURIComponent(selectedImagePath.toString())
                // console.log("Decoded file path: ", decodedFilePath)
            }
            else
            {
                audioChanged = true
                removeAudioButton.setVisible=true
                selectedAudioPath = fileDialog.selectedFile.toString()
                audio.source = selectedAudioPath
                playButton.setVisible=true
            }

        }
    }

    Rectangle
    {
        color:appColors.c_background
        anchors.fill: parent

        Rectangle
        {
            id:baseForm
            color:"transparent"
            width:parent.width/2
            height:parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            Column
            {
                width: parent.width
                height: parent.height
                spacing:15

                AnimatedImage
                {
                    id:picture
                    width:150
                    height:150
                    anchors.horizontalCenter: parent.horizontalCenter
                    onStatusChanged:
                    {
                        if (status === Image.Error)
                        {
                            console.warn("Image failed to load:", source);
                            visible=false
                        }
                        else
                            visible=true
                    }
                }
                Row
                {
                    id:imageControl
                    width:100
                    height:50
                    spacing:10
                    anchors.horizontalCenter: parent.horizontalCenter
                    Label
                    {
                        text:"image:"
                        color:appColors.c_fontcolor
                    }
                    CustomButtonWithIcon
                    {
                        setButtonText:"";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setIconSource: appIcons.icon_browse
                        setButtonsBorderWidth: 0
                        setIconWidth: 20
                        setIconHeight: 20
                        setRadius: 45
                        setWidth: 45
                        setHeight: 45
                        onButtonClicked:
                        {
                            //open picture dialog
                            fileDialogPickingImage=true
                            fileDialog.open()
                        }
                    }
                    CustomButtonWithIcon
                    {
                        id:removePictureButton
                        setButtonText:"";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonCancelBgColor
                        setButtonFontColor: appColors.c_buttonCancelFontColor
                        setIconSource: appIcons.icon_delete
                        setButtonsBorderWidth: 0
                        setIconWidth: 20
                        setIconHeight: 20
                        setVisible: (formData[6] && formData[6].length > 0) ? true : false
                        setRadius: 45
                        setWidth: 45
                        setHeight: 45
                        onButtonClicked:
                        {
                            removePicture=true;
                            picture.visible=false;
                            setVisible=false;
                        }
                    }

                }

                Row
                {
                    id:audioControl
                    width:100
                    height:50
                    spacing:10
                    anchors.horizontalCenter: parent.horizontalCenter
                    Label
                    {
                        text:"audio:"
                        color:appColors.c_fontcolor
                    }
                    CustomButtonWithIcon
                    {
                        setButtonText:"";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setIconSource: appIcons.icon_browse
                        setButtonsBorderWidth: 0
                        setIconWidth: 20
                        setIconHeight: 20
                        setRadius: 45
                        setWidth: 45
                        setHeight: 45
                        onButtonClicked:
                        {
                            //open picture dialog
                            fileDialogPickingImage=false
                            fileDialog.open()
                        }
                    }

                    CustomButtonWithIcon
                    {
                        id:removeAudioButton
                        setButtonText:"";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonCancelBgColor
                        setButtonFontColor: appColors.c_buttonCancelFontColor
                        setIconSource: appIcons.icon_delete
                        setButtonsBorderWidth: 0
                        setIconWidth: 20
                        setIconHeight: 20
                        setRadius: 45
                        setVisible: (formData[7] && formData[7].length > 0) ? true : false
                        setWidth: 45
                        setHeight: 45
                        onButtonClicked:
                        {
                            removeAudio=true;
                            setVisible=false
                            playButton.setVisible=false
                        }
                    }
                    CustomButtonWithIcon
                    {
                        id:playButton
                        setButtonText:"";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setIconSource: appIcons.icon_play
                        setButtonsBorderWidth: 0
                        setIconWidth: 20
                        setIconHeight: 20
                        setRadius: 45
                        setVisible: false
                        setWidth: 45
                        setHeight: 45
                        onButtonClicked:
                        {
                            if(audio.playing)
                            {
                                audio.play()
                                playButton.setIconSource= appIcons.icon_pause
                            }
                            else
                            {
                                audio.stop()
                                playButton.setIconSource= appIcons.icon_play
                            }
                        }
                    }

                }

                Repeater
                {
                    id: repeater
                    model: titleModel
                    delegate: CustomTextInput
                    {
                        setWidth: parent.width
                        setHeight: 50
                        setBgColor: appColors.c_bgColor_textinput
                        setBordercolor: appColors.c_borderColor_textinput
                        setBorderWidth:2
                        setFocus: index === 0
                        setFontSize:appFontSizes.f_textInput
                        setFontColor: appColors.c_fontColor_textinput
                        setRadius:10
                        setVisible: model.title==="status"? false : true
                        theText: model.text
                        setTitleText: model.title
                    }
                }

                CustomCombobox
                {
                    id: comboWordStatus
                    setBgColor: appColors.c_comboboxBgColor
                    setFontColor: appColors.c_buttonFontColor
                    setfontSize: appFontSizes.f_normal
                    setIconArrow: appIcons.icon_back_white
                    setWidth: parent.width/2
                    height:45
                    setPositionPopup:"top"
                    modelData: wordStatuses
                    setBgColorCurrentItem: appColors.c_comboboxBgColorCurrentItem
                    onActivated: function(index)
                    {
                        currentIndex = index
                    }
                }

                Row
                {
                    width:parent.width
                    height:50
                    spacing: 15

                    CustomButton
                    {
                        id:cancelButton
                        setButtonText:"cancel";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonCancelBgColor
                        setButtonFontColor: appColors.c_buttonCancelFontColor
                        setBold: true
                        setButtonFontsize: appFontSizes.f_buttonFontSize
                        setButtonsBorderWidth: 0
                        setRadius: 20
                        setWidth: 100
                        setHeight: 50
                        onButtonClicked:
                        {
                            parentName.routeBackFromModifyPage()
                        }
                    }

                    CustomButton
                    {
                        id:savebutton
                        setButtonText:"save";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setBold: true
                        setButtonFontsize: appFontSizes.f_buttonFontSize
                        setButtonsBorderWidth: 0
                        setRadius: 20
                        setWidth: 100
                        setHeight: 50
                        onButtonClicked:
                        {
                            if(wordId==-1 || formType==="none")
                                console.log("invalid wordId/formType to modify word.")
                            else
                            {
                                backend.modifyWordOnTable(wordId,
                                                          formType,
                                                          readDataFromRepeater(false,true));
                            }
                        }
                    }



                }

            }
        }


    }

    function refreshFormInputs()
    {
        titleModel.clear()
        var arr = []
        if (formType === "word")
            arr = wordTitles
        else
            console.log("formType unkown, formType=",formType)

        // console.log("refreshFormInputs data=")
        // for(var x=0; x< formData.length; x++)
        //     console.log("formdata[",x,"]=",formData[x])




        //inject/append form titles, form data into repeater's list
        for (var i = 0; i < arr.length; i++)
        {
            titleModel.append({"title": arr[i],
                               "text": formData[i] || ""
                              })
        }


        var index = wordStatuses.findIndex(function(item)
        {
            return item.text === formData[5];
        })
        comboWordStatus.currentIndex=index


        picture.source = "file://"+contentPath+formData[6];
        audio.source = "file://"+contentPath+formData[7];


    }

    function modifyWordValue(data,key,value)
    {
        for (var i = 0; i < data.length; ++i)
        {
            var row = data[i];
            if (key in row)
                row[key]=value;
        }
    }

    function readDataFromRepeater(wihtId=false,dataForBackend=false)
    {
        //read data from reapeater's items
        var data = [];

        //first item of formData is wordId need to fill before modfied data
        if(wihtId && !dataForBackend)
        {
            var obj2 = {};
            obj2["id"] = wordId;
            data.push(obj2);
        }




        for (var i = 0; i < repeater.count; i++)
        {
            var item = repeater.itemAt(i);
            if (item)
            {
                // console.log("Input " + i + ": " + item.setTitleText + " = " + item.theText);
                if(dataForBackend)
                    data.push(item.theText);
                else
                {
                    var obj = {};
                    obj[item.setTitleText] = item.theText;
                    data.push(obj);
                }
            }
            else
                console.log("invalid item repeater to read.")
        }



        //modify word status which hold by combobox
        let wordStatus = comboWordStatus.currentItemText
        if(dataForBackend)
            data[5]=wordStatus
        else
        {
            // data["status"]=wordStatus
            modifyWordValue(data,"status",wordStatus)
        }


        //check is picture modified/removed?
        var obj2 = {};
        if(pictureChanged)
        {
            // Extract the file name from the selected file path
            // Check if the selected file is a QUrl
            var filePath = selectedImagePath
            if (filePath)
                var fileName = filePath.split('/').pop();


            if(dataForBackend)
            {
                data.push(selectedImagePath)//new picture
                data.push(formData[6])//oldpciture
            }
            else
            {
                obj2["picture"] = fileName;
                data.push(obj2);
            }
        }
        else if(removePicture)
        {
            if(dataForBackend)
            {
                data.push("remove")//picture is removed
                data.push(formData[6])//oldpciture
            }
            else
            {
                obj2["picture"] = "";
                data.push(obj2);
            }
        }
        else
        {
            //data for practice included same picture path
            if(dataForBackend)
            {
                data.push("nochange")//picture didn't change at all
                data.push(formData[6])//old pic
            }
            else
            {
                obj2["picture"] = formData[6]; //same picture
                data.push(obj2);
            }
        }


        //check audio modifed/removed?
        if(audioChanged)
        {
            // Extract the file name from the selected file path
            // Check if the selected file is a QUrl
            var filePath = selectedAudioPath
            if (filePath)
                var fileName = filePath.split('/').pop();


            if(dataForBackend)
            {
                data.push(selectedAudioPath)//new audio
                data.push(formData[7])//old audio
            }
            else
            {
                obj2["audio"] = fileName;
                data.push(obj2);
            }
        }
        else if(removePicture)
        {
            if(dataForBackend)
            {
                data.push("remove")//audio is removed
                data.push(formData[7])//old audio
            }
            else
            {
                obj2["audio"] = "";
                data.push(obj2);
            }
        }
        else
        {
            //data for practice included same audio path
            if(dataForBackend)
            {
                data.push("nochange")//audio didn't change at all
                data.push(formData[7])//old audio
            }
            else
            {
                obj2["audio"] = formData[7]; //same audio
                data.push(obj2);
            }
        }



        // for (var x = 0; x < data.length; x++) {
        //     console.log("data[" + x + "] = " + JSON.stringify(data[x]));
        // }

        return data
    }


    function getValueByKey(dataList, firstKey) {
        if (!dataList || dataList.length === 0)
            return "";

        // Check if dataList is an array of objects
        if (Array.isArray(dataList)) {
            var mergedData = {};
            for (var i = 0; i < dataList.length; i++) {
                var item = dataList[i];
                for (var key in item) {
                    mergedData[key] = item[key];  // Merge all objects into one
                }
            }
            // Now mergedData is a single object with all keys
            if (firstKey in mergedData)
                return mergedData[firstKey];
        }
        else {
            // Assuming dataList is a single object
            var row = dataList[0]; // First object in the list
            if (firstKey in row)
                return row[firstKey];
        }

        return "";
    }



    function updateTextValues()
    {
        var tempData = []
        tempData.push(getValueByKey(formData,"text"))
        tempData.push(getValueByKey(formData,"meaning"))
        tempData.push(getValueByKey(formData,"example"))
        tempData.push(getValueByKey(formData,"translate"))
        tempData.push(getValueByKey(formData,"source"))
        tempData.push(getValueByKey(formData,"status"))
        tempData.push(getValueByKey(formData,"picture"))
        tempData.push(getValueByKey(formData,"audio"))

        formData=tempData
    }


    Connections
    {
        target: backend
        function onModifyWordOnTableResult(res)
        {
            console.log("onModifyWordOnTableResult=",res)
            if(res!=="error")
            {
                parentName.routeBackFromModifyPage(readDataFromRepeater(true,false))
            }
        }
    }
    Component.onCompleted:
    {
        // console.log("received data: wrodId:", wordId, "formtype:",formType, "formData:")
        // console.log("modifyWord received, formData=")
        // for (var i = 0; i < formData.length; ++i)
        // {
        //     var row = formData[i]
        //     for (var key in row)
        //     {
        //         console.log("formData:  " + key + ": " + row[key])
        //     }
        //     console.log("---")
        // }

        contentPath= backend.getContentPath()

        //fill form
        updateTextValues()
        refreshFormInputs()
    }

}

