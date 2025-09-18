import QtQuick
import QtQuick.Controls
import "../CustomComponents"

Page
{
    id:typePracticeCore
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
        width:parent.width
        height:parent.height

        Column
        {
            width:parent.width
            height:parent.height
            spacing:15
            anchors
            {
                top:parent.top
                topMargin:15
            }

            Row
            {
                width: parent.width
                height: 50
                spacing: 10

                Rectangle
                {
                    //spacer
                    color:"transparent"
                    width:parent.width/3.50
                    height:parent.height
                }

                CustomProccessBar
                {
                    id:proccessBar
                    currentValue:currentIndex-1
                    totalValue: maxIndex
                    setWidth: parent.width/3
                    setHeight: 20
                    setSpacing:0
                    setProgressRadius:0
                    setFontColor: appColors.c_fontcolor
                    setBgColor: appColors.c_bg_tableList
                    setFontSize: appFontSizes.f_normal
                    setProgressColor: appColors.c_buttonBgColor
                    setCotinainerRadius: parent.width
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
                    setIconSource: hideAllExceptFirstItem ? appIcons.icon_hide : appIcons.icon_eye
                    onButtonClicked:
                    {
                        hideAllExceptFirstItem = !hideAllExceptFirstItem;
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
                    setIconSource:  appIcons.icon_modify
                    onButtonClicked:
                    {
                        routeToModifyPage()
                    }
                }


            }

            Label
            {
                id:w_text
                text:""
                width: parent.width
                height:50
                font.pixelSize:appFontSizes.f_title
                font.bold: true
                color:appColors.c_fontcolor
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }


            Column
            {
                id:columnPractice
                width: parent.width
                height: parent.height-100
                spacing:25

                Label
                {
                    id:w_meaning
                    text:""
                    width: parent.width
                    height: text.length > 0 ? 100 : 0
                    visible: hideAllExceptFirstItem ? false : true
                    font.pixelSize:appFontSizes.f_large
                    color:appColors.c_fontcolor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
                Label
                {
                    id:w_example
                    text:""
                    visible: hideAllExceptFirstItem ? false : true
                    width: parent.width
                    height: text.length > 0 ? 100 : 0
                    font.pixelSize:appFontSizes.f_large
                    color:appColors.c_fontcolor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Label
                {
                    id:w_translate
                    text:""
                    visible: hideAllExceptFirstItem ? false : true
                    width: parent.width
                    height: text.length > 0 ? 100 : 0
                    font.pixelSize:appFontSizes.f_large
                    color:appColors.c_fontcolor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Rectangle
                {
                    color:"transparent"
                    width:parent.width/2
                    height:50
                    anchors.horizontalCenter: parent.horizontalCenter
                    CustomTextInput
                    {
                        id:text_input
                        setWidth: parent.width
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

                    CustomButtonWithIcon
                    {
                        id:buttonNext
                        setButtonText:"";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setIconSource:appIcons.icon_back_white
                        setIconWidth: 20
                        setIconHeight: 20
                        setIconFlipHorizontal: true
                        setButtonsBorderWidth: 0
                        setRadius: 45
                        setWidth: 45
                        setHeight: 45
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


        CustomTimer
        {
            id:practiceTimeCom
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

    function routeBackFromModifyPage(modifiedData=-1)
    {
        practiceCore.m_stackView.pop()

        if(modifiedData!==-1) //means modify canceled by user
        {
            updateTextValues()
            practiceData = modifiedData
        }

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
