import QtQuick
import QtQuick.Controls
import "CustomComponents"

Page
{
    id:practiceCore
    //to pass mainStackView from parent
    property var m_stackView: mainStackView

    //fill up outside/before pushing to mainStackView
    property string tableType: "none"
    property int tableId:-1
    property string tableName: ""


    //each practice can fill these values to report their result

    //fill in order by targetPractice(e.g: by typePractice.qml):
    //practiceTypeId codes: (typePractice:1, flashcardPractice:2)
    property var practiceResult: {"mistakeCount":"15", "timeSpent":"10:00:20", "practiceTypeId":1}

    header: Rectangle //this will appear on all practice pages
    {
        width: parent.width
        height: 60
        color: appColors.c_headerBg
        Label
        {
            id:headerText
            text:"Choose Practice"
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


        CustomButtonWithIcon
        {
            id:backToPracticePage
            setButtonText:"";
            setIconSource: appIcons.icon_back
            setButtonBorderColor: "transparent"
            setButtonBackColor: "transparent"
            setButtonFontColor: "transparent"
            setIconWidth: 20
            setIconHeight: 20
            setButtonsBorderWidth: 0
            setRadius: 50
            setWidth: 50
            setHeight:50
            anchors
            {
                left: parent.left
                leftMargin:5
                top:parent.top
                topMargin:5
            }
            onButtonClicked:
            {
                //if user is on result stage: hide result stage then go to select stage.
                if(resultBase.visible)
                {
                    resultBase.visible=false
                    quitMode(false)
                }
                //so we are not in stage result or practiceMode, can quit practicePage
                else if(practiceLoader.source.toString()==="")
                {
                    m_stackView.pop()
                }
                else //go to select stage.
                {
                    headerText.text = "Choose Practice"
                    quitMode(false)
                }

            }
        }


    }

    Loader
    {
        id:practiceLoader
        anchors.fill: parent
        visible: false
        source:""
    }


    Rectangle
    {
        id:selectPracticeBase
        anchors.fill: parent
        color:appColors.c_background

        CustomCollapsiblePanel
        {
            setTitle: "control content"
            setWidth: parent.width/1.5
            anchors.horizontalCenter: parent.horizontalCenter

            setBgColorButton: appColors.c_comboboxBgColor
            setTextColor: appColors.c_buttonFontColor
            setTextFontSize: appFontSizes.f_normal
            setIconArrow: appIcons.icon_back_white
            setBgContent:appColors.c_collapsContentBgColor

            setOpen: false
            setHeight: 60
            setContentHeight: 150
            Column
            {
                id:controlTableColumn
                width:parent.width
                height:150
                spacing:5
                Row
                {
                    id:resetPartOfTableRow
                    width:parent.width
                    height:50
                    spacing: 10
                    CustomCombobox
                    {
                        id: resetTypeCombobox
                        setBgColor: appColors.c_comboboxBgColor
                        setFontColor: appColors.c_buttonFontColor
                        setfontSize: appFontSizes.f_normal
                        setIconArrow: appIcons.icon_back_white
                        setWidth: 120
                        height:50
                        modelData: tableType==="word"?
                            [ {text:"status"},{ text:"translate"}, {text:"example"}, {text:"meaning"},{ text:"source"},{ text:"type"} ]
                            : [ {text:"status"}, {text:"translate"} ]
                        setBgColorCurrentItem: appColors.c_comboboxBgColorCurrentItem
                        onActivated: function(index)
                        {
                            currentIndex = index
                        }
                    }

                    CustomButton
                    {
                        setButtonText:"Reset"
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setBold: true
                        setButtonFontsize: appFontSizes.f_buttonFontSize
                        setButtonsBorderWidth: 0
                        setRadius: 20
                        setWidth: 70
                        setHeight: 50
                        onButtonClicked:
                        {
                            backend.setTableAllRows(resetTypeCombobox.currentItemText,"");
                        }
                    }

                }


                Row
                {
                    id:contentBackupManager
                    width:parent.width
                    height:50
                    spacing: 10
                    CustomButton
                    {
                        setButtonText:"Take Backup \nupload"
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setBold: true
                        setButtonFontsize: appFontSizes.f_buttonFontSize
                        setButtonsBorderWidth: 0
                        setRadius: 20
                        setWidth: 80
                        setHeight: 50
                        onButtonClicked:
                        {
                            backend.saveBackupTableContentToAPI();
                        }
                    }
                    CustomButton
                    {
                        setButtonText:"Download\nBackup"
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setBold: true
                        setButtonFontsize: appFontSizes.f_buttonFontSize
                        setButtonsBorderWidth: 0
                        setRadius: 20
                        setWidth: 80
                        setHeight: 50
                        onButtonClicked:
                        {
                            backend.getBackupTableContentFromAPI();
                        }
                    }
                    CustomButton
                    {
                        setButtonText:"Delete\nContent"
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setBold: true
                        setButtonFontsize: appFontSizes.f_buttonFontSize
                        setButtonsBorderWidth: 0
                        setRadius: 20
                        setWidth: 80
                        setHeight: 50
                        onButtonClicked:
                        {
                            backend.deleteTableContent();
                        }
                    }
                }



            }

        }

        Column
        {
            width:parent.width/2
            height:parent.height/2
            anchors.centerIn: parent
            spacing:25
            Row
            {
                width:parent.width
                height: tableType==="word"? 50 : 0
                visible: tableType==="word"
                spacing: 10
                CustomButton
                {
                    setButtonText:"Type Practice"
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setBold: true
                    setButtonFontsize: appFontSizes.f_buttonFontSize
                    setButtonsBorderWidth: 0
                    setRadius: 20
                    setWidth: parent.width-70
                    setHeight: parent.height
                    onButtonClicked:
                    {
                        joinMode("practiceModes/typePractice.qml", {practiceMode: tableType});
                        headerText.text = "Type Practice"
                    }
                }
                CustomButton
                {
                    setButtonText:"only ⭐"
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setBold: true
                    setButtonFontsize: appFontSizes.f_buttonFontSize
                    setButtonsBorderWidth: 0
                    setRadius: 20
                    setWidth: 50
                    setHeight:parent.height
                    onButtonClicked:
                    {
                        joinMode("practiceModes/typePractice.qml",
                                 {
                                     practiceMode: tableType,
                                     practiceOnlyStarred: true
                                 });
                        headerText.text = "Type Practice only starred words"
                    }
                }

            }


            Row
            {
                width:parent.width
                height: tableType==="word"? 50 : 0
                visible: tableType==="word"
                spacing: 10
                CustomButton
                {
                    setButtonText:"Flashcard Practice"
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setBold: true
                    setButtonFontsize: appFontSizes.f_buttonFontSize
                    setButtonsBorderWidth: 0
                    setRadius: 20
                    setWidth: parent.width-70
                    setHeight:parent.height
                    onButtonClicked:
                    {
                        joinMode("practiceModes/flashcardPractice.qml", {practiceMode: tableType});
                        headerText.text = "Flashcard Practice"
                    }
                }
                CustomButton
                {
                    setButtonText:"only ⭐"
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setBold: true
                    setButtonFontsize: appFontSizes.f_buttonFontSize
                    setButtonsBorderWidth: 0
                    setRadius: 20
                    setWidth: 50
                    setHeight:parent.height
                    onButtonClicked:
                    {
                        joinMode("practiceModes/flashcardPractice.qml",
                                 {
                                     practiceMode: tableType,
                                     practiceOnlyStarred: true
                                 });
                        headerText.text = "Flashcard Practice only starred words"
                    }
                }

            }



            CustomButton
            {
                setButtonText:"Crossword Practice"
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: parent.width
                setVisible: tableType==="word"
                setHeight: tableType==="word" ? 50 : 0
                anchors.horizontalCenter: parent.horizontalCenter
                onButtonClicked:
                {
                    joinMode("practiceModes/crosswordPractice.qml");
                    headerText.text = "Crossword Practice"
                }
            }

            CustomButton
            {
                setButtonText:"Type Practice"
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: parent.width
                setVisible: tableType==="customTable"
                setHeight: tableType==="customTable" ? 50 : 0
                anchors.horizontalCenter: parent.horizontalCenter
                onButtonClicked:
                {
                    joinMode("practiceModes/typePracticeCustomTable.qml", {selectedTableId:tableId});
                    headerText.text = "Type Practice CustomTable"
                }
            }
        }


    }


    Rectangle
    {
        id:resultBase
        color: appColors.c_background
        anchors.fill: parent
        visible: false;

        Column
        {
            width:parent.width/2
            height:parent.height/2
            anchors.centerIn: parent
            spacing:25

            Label
            {
                text: "mistakes: " + practiceResult["mistakeCount"]
                font.pixelSize: appFontSizes.f_large
                color: appColors.c_fontcolor
            }

            Label
            {
                text: "time spent: " + practiceResult["timeSpent"]
                font.pixelSize: appFontSizes.f_large
                color: appColors.c_fontcolor
            }

            CustomButton
            {
                setButtonText:"OK"
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: parent.width
                setHeight:50
                anchors.horizontalCenter: parent.horizontalCenter
                onButtonClicked:
                {
                    closeResult()
                }
            }
        }
    }



    function quitMode(saving=true,message="")
    {
        console.log("quitMode called. saving:",saving)
        practiceLoader.visible=false
        practiceLoader.source = ""

        if(saving===true)
        {
            resultBase.visible=true
            //saving on database, in order (mistakecount(str), timespent(str), practiceTypeid(int)
            backend.setPracticeResult(practiceResult["mistakeCount"],
                                      practiceResult["timeSpent"],
                                      practiceResult["practiceTypeId"]);
        }
        else
            selectPracticeBase.visible=true

        if(message.length>1)
            console.log("quitMode message=",message)
    }



    function closeResult()
    {
        resultBase.visible=false
        selectPracticeBase.visible=true
    }

    function joinMode(practiceSource, params = {})
    {
        practiceLoader.visible = true;
        selectPracticeBase.visible = false;

        if (Object.keys(params).length === 0)
            practiceLoader.source = practiceSource;
        else
            practiceLoader.setSource(practiceSource, params);
    }
    Connections
    {
        target:backend
        function onUploadDone(result)
        {
            console.log("upload content backup done resutt=",result)
        }
        function onDownloadFinished(success, filePath)
        {
            console.log("download content finished result=",success, "path=",filePath)
            //assuming downloaded successfully
            backend.unarchiveQpack(filePath)

        }
    }
    Component.onCompleted:
    {
        appVisibleBackOrMenuButton=false
    }
    Component.onDestruction:
    {
        appVisibleBackOrMenuButton=true
    }
}
