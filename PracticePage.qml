import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Page
{
    width:parent.width
    height: parent.height
    property int currentIndex: 0;
    property int mistakesCounter : 0;

    property var m_stackView: mainStackView
    property string practiceMode: "word" //word or verb

    //for practice verb needs to user type whole three inputs to get next word:
    property int passedState:0;

    property bool quitPracticeStatus: false

    Rectangle
    {
        id:mainRect
        color:appColors.c_background
        anchors.fill: parent
        CustomProccessBar
        {
            id:proccessBar
            currentValue:currentIndex
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
                topMargin: appKeyboardVisible ? appKeyboardHeight : 15
            }
        }

        Item
        {
            id:itemContent
            anchors.fill: parent
            PracticeTimeComponent
            {
                id:practiceTimeCom
                onEachTrigger:
                {
                    if(quitPracticeStatus)
                        quitPractice()
                }
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
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Label
                {
                    id:w_meaning
                    text:""
                    font.pixelSize:appFontSizes.f_title
                    color:appColors.c_fontcolor
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }
                Label
                {
                    id:w_example
                    text:""
                    font.pixelSize:appFontSizes.f_title
                    color:appColors.c_fontcolor
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Rectangle
                {
                    color:"transparent"
                    width:parent.width
                    height:50
                    // anchors.horizontalCenter: parent.horizontalCenter
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
                        setFocus: true
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
                        setWidth: 80
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

    }

    Rectangle
    {
        id:finishRect
        color:"lime"
        anchors.fill: parent
        visible: false;


        Column
        {
            width:parent.width/2
            height:parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            spacing:25

            Text
            {
                id:mistakesCount
                text: "mistakes: "
            }

            Text
            {
                id:timeSpent
                text: "time spent: "
            }

            Button
            {
                text:"quit practice"
                onClicked:
                {
                    quitPractice()
                }
            }

            Button
            {
                text:"start again"
                onClicked:
                {
                    startPractice()
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
                {
                    backend.getNextWord(text_input.theText)
                }
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
                            backend.getNextWord(w_text.text)//to get next one
                            text_input.clear()
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
        console.log("mistakeMade...");
        text_input.invalidInput("incorrect value")
    }

    function quitPractice()
    {
        backend.resetPractice(); //after this, lastWord on backend will become -> "" and we cant get first word by passing ""
        // currentIndex=0;
        // mistakesCounter=0;
        practiceTimeCom.stopTimer()
        m_stackView.pop()
        console.log("quiting the practice");
    }

    function startPractice()
    {

        mainRect.visible=true
        finishRect.visible=false


        backend.resetPractice()

        //to fetch first word and get maxium number of content on table
        var totalWords = backend.getNextWord("");
        if(totalWords<=0)
            quitPracticeStatus=true
        else
            proccessBar.totalValue = totalWords

        currentIndex=0;
        mistakesCounter=0;
        practiceTimeCom.startTimer()

    }


    Connections
    {
        target: backend
        function onWordReady(word)
        {
            w_text.text = word[0]
            w_meaning.text = word[1]
            w_example.text = word[2]
            text_input.clear()
            if(practiceMode==="verb")
            {
                passedState=0;


                //verb is inside w_text
                //past is inside w_meaning
                //past perfect is inside w_example
                w_text.font.bold=true
                w_meaning.font.bold=false;
                w_example.font.bold=false;
            }

            //logic to check if practice is end, show results
            if(currentIndex>=proccessBar.totalValue-1)
            {
                //switch to result
                mainRect.visible=false
                finishRect.visible=true
                currentIndex=0;
                mistakesCount.text= "mistakes: "+ mistakesCounter //because first time it starts
                timeSpent.text =  "time spent: "+ practiceTimeCom.timerString

                //save practice result on backend
                backend.setPracticeResult(mistakesCounter,practiceTimeCom.timerString);
            }
            else
                currentIndex++;
        }
        function onWordIsIncorrect(correctStatus)
        {
            if(correctStatus==="incorrect")
            {
                mistakeMade();
            }
        }
    }

    Component.onCompleted:
    {
        startPractice()
    }
    Component.onDestruction:
    {
        quitPractice();
    }
}
