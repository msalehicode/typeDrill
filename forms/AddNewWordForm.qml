import QtQuick
import QtQuick.Controls
import "../CustomComponents"
import QtQuick.Dialogs
import QtMultimedia

Page
{
    id:addNewWordForm
    property string formType: "none"

    //data order passed by QML to backend
    //word: text, meaning, example, translate, source, status
    //verb: verb, past, past perfect, translate, status
    property var wordTitles: ["Enter Word:", "Enter Meaning:", "Enter Example:", "Enter Translate:", "Enter Source:", "Enter Status:"]
    property var verbTitles: ["Enter Verb:","Enter Past:", "Enter Past Participle:", "Enter Translate:","Enter Status:"]

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

    property string selectedImagePath : ""
    property string selectedAudioPath : ""

    ListModel
    {
        id: titleModel
    }



    onFormTypeChanged:
    {
        refreshFormInputs()
    }

    header: Rectangle
    {
        width: parent.width
        height: 60
        color: appColors.c_headerBg
        Label
        {
            id:headerText
            text:"Choose Table To Add Content"
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
            if(fileDialogPickingImage)
            {
                selectedImagePath = selectedFile
                removePictureButton.setVisible=true
            }
            else
            {
                selectedAudioPath = selectedFile
                removeAudioButton.setVisible=true
            }
        }

    }

    Rectangle
    {
        color:appColors.c_background
        anchors.fill: parent

        Rectangle
        {
            id:baseSelectTable
            color:"transparent"
            anchors.fill: parent
            visible: true

            CustomCombobox
            {
                id: tablesComboBox
                setBgColor: appColors.c_comboboxBgColor
                setFontColor: appColors.c_buttonFontColor
                setIconArrow: appIcons.icon_back_white
                setBgColorCurrentItem: appColors.c_comboboxBgColorCurrentItem
                anchors.centerIn: parent
                onActivated: function(index)
                {
                    currentIndex = index
                }
            }

            CustomButton
            {
                setButtonText:"select";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 100
                setHeight: 50
                anchors.top: tablesComboBox.bottom
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter
                onButtonClicked:
                {
                    if(tablesComboBox.currentIndex>=0)
                    {
                        //because we need payload or that table type (t_type)
                        //don't call tablesComboBox.currentItemText
                        var selectedItem = tablesComboBox.modelData[tablesComboBox.currentIndex]
                        backend.switchTable(selectedItem.text,selectedItem.t_type);
                        backend.whatIsCurrentTableType();
                        baseForm.visible=true
                        baseSelectTable.visible=false
                        headerText.text="Add Content To Table ("+selectedItem.text+")"
                    }
                }
            }
        }


        Rectangle
        {
            id:baseForm
            visible: false
            color:"transparent"
            width:parent.width/2
            height:parent.height

            anchors
            {
                top:parent.top
                topMargin:45
                horizontalCenter: parent.horizontalCenter
            }
            Column
            {
                width: parent.width
                height: parent.height
                spacing:25
                Row
                {
                    id:imageControl
                    width:100
                    height:100
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
                        setVisible: false
                        setRadius: 45
                        setWidth: 45
                        setHeight: 45
                        onButtonClicked:
                        {
                            picture.visible=false;
                            selectedImagePath=""
                            picture.source=""
                            setVisible=false;
                        }
                    }

                }


                Row
                {
                    id:audioControl
                    width:100
                    height:100
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
                        setVisible: false
                        setWidth: 45
                        setHeight: 45
                        onButtonClicked:
                        {
                            selectedAudioPath=""
                            audio.source=""
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
                        theText:""
                        setTitleText: model.title
                    }
                }

                CustomButton
                {
                    setButtonText:"add";
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setBold: true
                    setButtonFontsize: appFontSizes.f_buttonFontSize
                    setButtonsBorderWidth: 0
                    setRadius: 20
                    setWidth: 100
                    setHeight: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    onButtonClicked:
                    {
                        var data = [];
                        for (var i = 0; i < repeater.count; i++)
                        {
                            var item = repeater.itemAt(i);
                            // console.log("Input " + i + ": " + item.theText);
                            if (item)
                                data.push(item.theText);
                        }

                        //add picture to data:
                        data.push(selectedImagePath);

                        //add audio to data:
                        data.push(selectedAudioPath);


                        //check empty items
                        if(data[0]==="" || data[0]===" ")
                            console.log("you must fill first item atleast")
                        else
                            backend.addWordToTable(data);
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
        else if (formType === "verb")
            arr = verbTitles
        else
            console.log("formType unkown, formType=",formType)


        for (var i = 0; i < arr.length; i++)
        {
            titleModel.append({"title": arr[i]})
        }
    }

    Connections
    {
        target: backend
        function onTableTypeIs(currentTableType)
        {
            formType=currentTableType
        }
        function onAddItemtoTableResult(res)
        {
            if (res !== "error")
            {
                //reset form for next word
                refreshFormInputs()
                console.log("word added into the table. res="+res)
                //go to homePage
                // mainStackView.pop();
                // mainStackView.pop();
            }
            else
                console.log("error: cant add word to table.. res=" + res)
        }

        function onTablesList(tables)
        {
            // console.log("Received tables list with", tables.length, "rows");
            var data = []
            for (var i = 0; i < tables.length; ++i)
            {
                var row = tables[i];
                // console.log("Row", i, "t_id:", row.t_id, "t_title:", row.t_title, "t_status:", row.t_status);
                data.push({
                                                t_id: row.t_id,
                                                t_text: row.t_title,
                                                t_type: row.t_type,
                                                text: row.t_title,
                                                value: row.t_status
                                            });
            }
            tablesComboBox.modelData=data;
        }
    }
    Component.onCompleted:
    {
        //first time fetch data from backend
        backend.getTables("","all")//empty string is for filter/search between tables, we dont want filter
    }

}

