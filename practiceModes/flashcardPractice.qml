import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"


Page {
    id: root
    width: 400
    height: 600

    property bool showInfo:false

    property int mistakesCounter:0

    property int maxWordId: 0
    property int currentWordId:0

    property var currentWord: {
        "word": "Apple",
        "translate": "Elma",
        "meaning": "A fruit",
        "example": "An apple a day keeps the doctor away."
    }
    PracticeTimeComponent
    {
        id:practiceTimeCom
    }

    Rectangle
    {
        anchors.fill: parent
        color:appColors.c_background
        CustomProccessBar
        {
            id:proccessBar
            currentValue:currentWordId
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

        Rectangle
        {
            id: card
            width: parent.width * 0.8
            height: parent.height * 0.5
            anchors.centerIn: parent
            color: appColors.c_bg_weekReport
            radius: 12
            transformOrigin: Item.Center
            clip:true

            Rotation
            {
                id: rotationTransform
                origin.x: card.width / 2
                origin.y: card.height / 2
                axis { x: 0; y: 1; z: 0 }
                angle: 0
            }

            transform: [rotationTransform]

            Item
            {
                id: frontFace
                anchors.fill: parent
                visible: !showInfo  && !flipAnimation.running
                Label
                {
                    anchors.centerIn: parent
                    text: currentWord.word
                    font.pixelSize: appFontSizes.f_title
                    font.bold: true
                    color: appColors.c_fontcolor
                }
            }

            Item
            {
                id: backFace
                width:parent.width/2
                height:parent.height/2
                anchors.centerIn: parent
                visible: showInfo && !flipAnimation.running
                Column
                {
                    anchors.fill: parent
                    spacing: 10
                    Label
                    {
                        width: parent.width
                        height: parent.height/3
                        text: "Translate: \n" + currentWord.translate
                        font.pixelSize: appFontSizes.f_large
                        color: appColors.c_fontcolor
                        wrapMode: Text.WordWrap
                    }
                    Label
                    {
                        width: parent.width
                        height: parent.height/3
                        text: "Meaning: \n" + currentWord.meaning
                        font.pixelSize: appFontSizes.f_large
                        color: appColors.c_fontcolor
                        wrapMode: Text.WordWrap
                    }
                    Label
                    {
                        width: parent.width
                        height: parent.height/3
                        text: "Example: \n" + currentWord.example
                        font.pixelSize: appFontSizes.f_large
                        color: appColors.c_fontcolor
                        wrapMode: Text.WordWrap
                    }
                }
            }

            SequentialAnimation
            {
                id: flipAnimation
                running: false

                PropertyAnimation
                {
                    target: rotationTransform
                    property: "angle"
                    from: 0
                    to: 90
                    duration: 200
                }

                PropertyAnimation
                {
                    target: rotationTransform
                    property: "angle"
                    from: 90
                    to: 180
                    duration: 200
                }

                onRunningChanged:
                {
                    if (!running)
                        rotationTransform.angle = 0 // Reset after flip
                }
            }


            // New animation for sliding card left or right
            PropertyAnimation {
                id: tiltAnimation
                target: rotationTransform
                property: "angle"
                duration: 300
                easing.type: Easing.InOutQuad
                from: 0
                to: 20  // or -20 for left tilt
                running: false
                onStopped: {
                    rotationTransform.angle = 0  // reset rotation after tilt
                }
            }


            MouseArea {
                anchors.fill: parent
                drag.axis: Drag.XAxis

                property real startX: 0
                property bool dragging: false

                // onClicked:
                // {
                //     showDetails()
                // }
                onPressAndHold:
                {
                    showDetails()
                }

                onPressed: function(mouse)
                {
                    startX = mouse.x
                    dragging = true
                }

                onReleased: function(mouse)
                {
                    dragging = false
                    var deltaX = mouse.x - startX

                    if (Math.abs(deltaX) > 100)
                    {
                        if (deltaX > 0)
                        {
                            // console.log("swiped right")
                            tiltAnimation.to = 50
                            tiltAnimation.start()
                            getNextWord()
                        }
                        else
                        {
                            // console.log("swiped left")
                            tiltAnimation.to = -50
                            tiltAnimation.start()
                            mistakeMade()
                        }
                    }
                }
            }
        }

        Rectangle
        {
            id:cardControlButtons
            width: card.width
            height:70
            color:"transparent"
            anchors.top:card.bottom
            anchors.left: card.left

            CustomButton
            {
                setButtonText:"i don't know it";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 100
                setHeight:50
                anchors.left:parent.left
                anchors.verticalCenter: parent.verticalCenter
                onButtonClicked:
                {
                    mistakeMade()
                }
            }

            CustomButton
            {
                setButtonText: !showInfo ? "Show Details" : "Show Word"
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 100
                setHeight:50
                anchors.centerIn: parent
                onButtonClicked:
                {
                    showDetails()
                }
            }

            CustomButton
            {
                setButtonText:"i know it";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 100
                setHeight:50
                anchors.right:parent.right
                anchors.verticalCenter: parent.verticalCenter
                onButtonClicked:
                {
                    getNextWord()
                }
            }

        }

    }


    function mistakeMade()
    {
        mistakesCounter++
        getNextWord()
    }

    function showDetails()
    {
        if (!flipAnimation.running)
        {
            showInfo = !showInfo
            flipAnimation.start()
        }
    }

    function getNextWord()
    {
        //flip card to word
        if(showInfo)
            showDetails()




        //check for finished list/words
        if(currentWordId>=maxWordId-1)
        {
            //finished
            practiceTimeCom.stopTimer()

            //set parent's result, and quit
            practiceCore.practiceResult = {"mistakeCount":mistakesCounter,
                                           "timeSpent":practiceTimeCom.timerString,
                                           "practiceTypeId":appPracticeTypesList["flashcardPractice"]}
            practiceCore.quitMode()
        }
        else
        {
            currentWordId++;
            backend.getNextWord(currentWord.word)
        }
    }

    Connections
    {
        target: backend
        function onWordReady(word)
        {
            // console.log("word=", word)
            currentWord =
                    {
                word: word[0],
                translate: word[1],
                meaning: word[2],
                example: word[3] ?? ""
            }
            // root.showDetails = false
        }
    }

    Component.onCompleted:
    {
        backend.resetPractice()
        maxWordId = backend.getNextWord("")

        if(maxWordId<=0)//this table doesn't have enough words
            practiceCore.quitMode(false,"this table doesn't have enough words to practice, add some word..")
        else
            proccessBar.totalValue = maxWordId

        practiceTimeCom.startTimer()
    }
}
