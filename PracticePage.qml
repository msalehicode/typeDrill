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


    property string practiceMode: "word" //word or verb

    //for practice verb needs to type whole three inputs:
    property int passedState:0;


    Rectangle
    {
        id:mainRect
        color:"#222424"
        anchors.fill: parent
        CustomProccessBar
        {
            id:proccessBar
            currentValue:currentIndex
        }

        Item
        {
            id:itemContent
            anchors.fill: parent
            PracticeTimeComponent
            {
                id:practiceTimeCom
            }

            ColumnLayout
            {
                id:columnPractice
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing:50
                Label
                {
                    id:w_text
                    text:"w_text"
                    font.pixelSize: 45
                    color:"white"
                    horizontalAlignment: Text.AlignHCenter  // Center text horizontally
                    Layout.fillWidth: true                   // Fill the available width
                    wrapMode: Text.WordWrap                  // Enable text wrapping if text is long

                }
                Label
                {
                    id:w_meaning
                    text:"w_meaning"
                    font.pixelSize: 25
                    color:"white"
                    horizontalAlignment: Text.AlignHCenter  // Center text horizontally
                    Layout.fillWidth: true                   // Fill the available width
                    wrapMode: Text.WordWrap                  // Enable text wrapping if text is long
                }
                Label
                {
                    id:w_example
                    text:"w_example"
                    font.pixelSize: 25
                    color:"white"
                    horizontalAlignment: Text.AlignHCenter  // Center text horizontally
                    Layout.fillWidth: true                   // Fill the available width
                    wrapMode: Text.WordWrap                  // Enable text wrapping if text is long
                }
                Rectangle
                {
                    width: 200;
                    height: 50
                    Layout.alignment: Qt.AlignHCenter   // Align horizontally center in layout
                    color:"transparent"
                    border.color: "grey";
                    TextInput
                    {
                        id:text_input
                        text:"type"

                        color:"white"
                        font.pixelSize: 30
                        anchors.fill: parent
                        focus: true;
                        onTextChanged:
                        {
                            text_input.color="white"
                        }

                        onAccepted:
                        {

                            switch(practiceMode)
                            {
                                case "word":
                                {
                                    if(text_input.length>=1)
                                    {
                                        text_input.color="white"
                                        backend.getNextWord(text_input.text)
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
                                            if(text===w_text.text)
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
                                            if(text===w_meaning.text)
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
                                            if(text===w_example.text)
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
                    mainStackView.pop();
                    quitPractice();
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

    function mistakeMade()
    {
        mistakesCounter++;
        text_input.color="red"
    }

    function quitPractice()
    {
        backend.resetPractice(); //after this, lastWord on backend will become -> "" and we cant get first word by passing ""
        currentIndex=0;
        mistakesCounter=0;
        practiceTimeCom.stopTimer()
        console.log("quiting the practice");
    }

    function startPractice()
    {

        mainRect.visible=true
        finishRect.visible=false


        backend.resetPractice()

        //to fetch first word and get maxium number of content on table

        proccessBar.totalValue = backend.getNextWord("")
        console.log("proccessBar.totalValue="+proccessBar.totalValue)
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
