import QtQuick
import QtQuick.Controls
import "../CustomComponents"

Page
{
    id:typePracticeCore
    width: parent ? parent.width : 400
    height: parent ? parent.height : 400


    //this will set from parent before start.
    property string practiceMode: "none" //word or verb

    property bool isThisWordModified: false;


    //a flag to hide/filter e.g: past,p.p of verb
    property bool hideAllExceptFirstItem: false;

    //private
    property int mistakesCounter : 0;
    property int currentIndex: 0;
    property int maxIndex: 100;

    //for practice verb needs to user type whole three inputs to get next word:
    property int passedState:0;


    property var practiceData: []
    Rectangle
    {
        id:mainRect
        color:appColors.c_background
        anchors.fill: parent


        CustomProccessBar
        {
            id:proccessBar
            currentValue:currentIndex-1
            totalValue: maxIndex
            setWidth: parent.width/2
            setHeight: 20
            setSpacing:0
            setProgressRadius:0
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
                topMargin:65
            }
        }

        CustomButtonWithIcon
        {
            id:modifyWordButton
            setWidth:30
            setHeight:30
            setButtonText:"";
            setButtonBorderColor: "transparent";
            setButtonFontColor:appColors.c_fontcolor;
            setButtonBackColor:"transparent"
            setTextMagin: 5
            setIconHeight: 25
            setIconWidth: 25
            anchors.top:proccessBar.top
            anchors.right: parent.right
            anchors.rightMargin: 15
            setIconSource:  appIcons.icon_modify
            onButtonClicked:
            {
                routeToModifyPage()
            }
        }

        CustomButtonWithIcon
        {
            id:hideAllExceptFirstItemButton
            setWidth:30
            setHeight:30
            setButtonText:"";
            setButtonBorderColor: "transparent";
            setButtonFontColor:appColors.c_fontcolor;
            setButtonBackColor:"transparent"
            setTextMagin: 5
            setIconHeight: 25
            setIconWidth: 25
            anchors.top:modifyWordButton.top
            anchors.right: modifyWordButton.left
            anchors.rightMargin: 15
            setIconSource: hideAllExceptFirstItem ? appIcons.icon_hide : appIcons.icon_eye
            onButtonClicked:
            {
                hideAllExceptFirstItem = !hideAllExceptFirstItem;
            }
        }


        CustomTimer
        {
            id:practiceTimeCom
        }

        Column
        {
            id:columnPractice
            width: parent.width/2
            height: parent.height/2
            anchors.centerIn: parent
            spacing:25
            Label
            {
                id:w_text
                text:""
                width: parent.width
                height:parent.height/10
                font.pixelSize:appFontSizes.f_title
                color:appColors.c_fontcolor
                // horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label
            {
                id:w_meaning
                text:""
                width: parent.width
                height:parent.height/10
                visible: hideAllExceptFirstItem ? false : true
                font.pixelSize:appFontSizes.f_title
                color:appColors.c_fontcolor
                // horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Label
            {
                id:w_example
                text:""
                visible: hideAllExceptFirstItem ? false : true
                width: parent.width
                height:parent.height/10
                font.pixelSize:appFontSizes.f_title
                color:appColors.c_fontcolor
                // horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label
            {
                id:w_translate
                text:""
                // visible: text.length>0 ? true : false
                visible: hideAllExceptFirstItem ? false : true
                width: parent.width
                height:parent.height/10
                font.pixelSize:appFontSizes.f_title
                color:appColors.c_fontcolor
                // horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Rectangle
            {
                color:"transparent"
                width:parent.width
                height:50
                anchors.horizontalCenter: parent.horizontalCenter
                CustomTextInput
                {
                    id:text_input
                    setWidth: parent.width-100
                    setHeight: parent.height
                    setBgColor: appColors.c_bgColor_textinput
                    setBordercolor: appColors.c_borderColor_textinput
                    setBorderWidth:2
                    setFontSize:appFontSizes.f_textInput
                    setFontColor: appColors.c_fontColor_textinput
                    setRadius:10
                    theText:""
                    setErrorPosfix: ""
                    setErrorPrefix: ""
                    setTitleText:""
                    onTheTextAccepted:
                    {
                        checkVerbState()
                    }
                }

                CustomButton
                {
                    id:buttonNext
                    setButtonText:"next";
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setBold: true
                    setButtonFontsize: appFontSizes.f_buttonFontSize
                    setButtonsBorderWidth: 0
                    setRadius: 20
                    setWidth: 60
                    setHeight: 50
                    anchors
                    {
                        top:text_input.top
                        left:text_input.right
                        leftMargin:5
                    }
                    onButtonClicked:
                    {
                        checkVerbState()
                    }
                }
            }
        }
    }


    function checkVerbState()
    {
        switch(practiceMode)
        {
            case "word":
            {
                if(text_input.theText.length>=1)
                    getNextWord(text_input.theText)
            }break;

            case "verb":
            {
                //verb is inside w_text
                //past is inside w_meaning
                //past perfect is inside w_example
                switch(passedState)
                {
                    case 0:
                    {
                        if(text_input.theText===w_text.text)
                        {
                            passedState++;
                            text_input.clear()
                            w_text.font.bold=false
                            w_meaning.font.bold=true;
                            w_example.font.bold=false;
                        }
                        else
                            mistakeMade();
                    }break;
                    case 1:
                    {
                        if(text_input.theText===w_meaning.text)
                        {
                            passedState++;
                            text_input.clear()
                            w_text.font.bold=false
                            w_meaning.font.bold=false;
                            w_example.font.bold=true;
                        }
                        else
                            mistakeMade();
                    }break;
                    case 2:
                    {
                        if(text_input.theText===w_example.text)
                        {
                            getNextWord(w_text.text)

                            //reset for next round
                            text_input.clear()
                            passedState=0;
                        }
                        else
                            mistakeMade();
                    }break;
                    default:
                        console.log("passedState invalid.")
                }

            }break;
        }
    }


    function mistakeMade()
    {
        mistakesCounter++;
        text_input.invalidInput("incorrect value");

    }

    function getNextWord(text)
    {
        backend.getNextWord(text, isThisWordModified)

        //turn flag off for next word
        isThisWordModified=false
    }

    function quitPractice()
    {
        practiceTimeCom.stopTimer()

        //set parent's result, and quit
        practiceCore.practiceResult=[mistakesCounter,practiceTimeCom.timerString]

        practiceCore.practiceResult = {"mistakeCount":mistakesCounter,
                                       "timeSpent":practiceTimeCom.timerString,
                                       "practiceTypeId":appPracticeTypesList["typePractice"]}
        practiceCore.quitMode()
    }

    function startPractice()
    {
        backend.resetPractice()
        practiceTimeCom.startTimer()

        //to fetch first word and get maxium number of content on table
        var totalWords = backend.getNextWord("firstword");


        if(totalWords<=0)
        {
            //this table doesn't have enough words
            practiceCore.quitMode(false,"this table doesn't have enough words to practice, add some word..")
        }
        else
            maxIndex = totalWords //because first id of word is 1
    }

    function routeToModifyPage()
    {
        text_input.clear()
        isThisWordModified=true;
        practiceTimeCom.pauseTimer()
        practiceCore.m_stackView.push("../forms/ModifyWordForm.qml",
                                          {"formType":practiceMode,
                                          "wordId":currentIndex,
                                          "formData": practiceData,
                                          "parentName": typePracticeCore})
    }

    function routeBackFromModifyPage(modifiedData)
    {
        practiceCore.m_stackView.pop()
        practiceData = modifiedData

        /*
        console.log("routeBackFromModifyPage, data=")
        for (var i = 0; i < practiceData.length; ++i)
        {
            var row = practiceData[i]
            for (var key in row)
            {
                console.log("  " + key + ": " + row[key])
            }
            console.log("---")
        }*/

        updateTextValues()
        practiceTimeCom.resumeTimer()
    }

    function getValueByKey(dataList, firstKey, secondKey)
    {
        if (!dataList || dataList.length === 0)
            return "";

        for (var i = 0; i < dataList.length; ++i)
        {
            var row = dataList[i];
            if (firstKey in row)
                return row[firstKey];
            else if (secondKey in row)
                return row[secondKey];
        }
        return "";
    }

    function updateTextValues()
    {
        w_text.text=getValueByKey(practiceData,"text","verb")
        w_meaning.text=getValueByKey(practiceData,"meaning","past")
        w_example.text=getValueByKey(practiceData,"example","past_perfect")
        w_translate.text=getValueByKey(practiceData,"translate","translate")
        currentIndex=getValueByKey(practiceData,"id","id")
    }


    Connections
    {
        target: backend
        function onPracticeFinished()
        {
            quitPractice()
        }

        function onWordReady(word)
        {
            practiceData=word
            updateTextValues()

            text_input.clear()
            if(practiceMode==="verb")
            {
                //verb is inside w_text
                //past is inside w_meaning
                //past perfect is inside w_example
                w_text.font.bold=true
                w_meaning.font.bold=false;
                w_example.font.bold=false;
            }                

        }
        function onWordIsIncorrect(correctStatus)
        {
            if(correctStatus==="incorrect")
                mistakeMade();

        }
    }

    Component.onCompleted:
    {
        startPractice()
    }
}
