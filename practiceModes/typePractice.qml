import QtQuick
import QtQuick.Controls
import "../"

Page
{
    width: parent ? parent.width : 400
    height: parent ? parent.height : 400

    //this will set from parent before start.
    property string practiceMode: "none" //word or verb


    //private
    property int mistakesCounter : 0;
    property int currentIndex: 0;

    //for practice verb needs to user type whole three inputs to get next word:
    property int passedState:0;


    Rectangle
    {
        id:mainRect
        color:appColors.c_background
        anchors.fill: parent
        CustomProccessBar
        {
            id:proccessBar
            currentValue:currentIndex-1
            setWidth: parent.width/2
            setHeight: 20
            setSpacing:1
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
                topMargin:55
            }
        }


        PracticeTimeComponent
        {
            id:practiceTimeCom
        }

        Column
        {
            id:columnPractice
            width: parent.width/2
            height: parent.height/2
            anchors.centerIn: parent
            spacing:50
            Label
            {
                id:w_text
                text:""
                font.pixelSize:appFontSizes.f_title
                color:appColors.c_fontcolor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Label
            {
                id:w_meaning
                text:""
                font.pixelSize:appFontSizes.f_title
                color:appColors.c_fontcolor
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
            Label
            {
                id:w_example
                text:""
                font.pixelSize:appFontSizes.f_title
                color:appColors.c_fontcolor
                horizontalAlignment: Text.AlignHCenter
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
                    backend.getNextWord(text_input.theText)
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
                            // console.log("w_text.text=",w_text.text)
                            backend.getNextWord(w_text.text)
                            text_input.clear()
                            passedState=0;//for next round
                        }
                        else
                            mistakeMade();
                    }break;
                    default:
                        console.log("passedState invalid.")
                }

            }break;
        }
        text_input.openPhoneKeyboard()
    }


    function mistakeMade()
    {
        mistakesCounter++;
        text_input.invalidInput("incorrect value");
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
        var totalWords = backend.getNextWord("");


        if(totalWords<=0)
        {
            //this table doesn't have enough words
            practiceCore.quitMode(false,"this table doesn't have enough words to practice, add some word..")
        }
        else
            proccessBar.totalValue = totalWords
    }


    Connections
    {
        target: backend
        function onWordReady(word)
        {
            // for(var i=0;i<=word.length; i++)
                // console.log("wordready,word[",i,"]=",word[i])

            w_text.text = word[0]
            w_meaning.text = word[1]
            w_example.text = word[2]
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

            //logic to check if practice is end, show results
            if(currentIndex>=proccessBar.totalValue)
                quitPractice()
            else
                currentIndex++;
        }
        function onWordIsIncorrect(correctStatus)
        {
            if(correctStatus==="incorrect")
                mistakeMade();
        }
    }


    Component.onCompleted:
    {
        console.log("practiceMode=",practiceMode)
        startPractice()
    }
}
