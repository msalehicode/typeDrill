import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../"


Page {
    id: flashcardPracticeCore
    width: 400
    height: 600

    property bool showInfo:false

    property int mistakesCounter:0

    property int maxWordId: 0
    property int currentWordId:0


    property bool isThisWordModified: false;

    property var currentWord:
    {
        "text": "Apple",
        "meaning": "A fruit",
        "example": "An apple a day keeps the doctor away.",
        "translate": "Elma"
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
                    id:lblText
                    anchors.centerIn: parent
                    text: ""
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
                        id:lblTranslate
                        width: parent.width
                        height: parent.height/3
                        text:""
                        font.pixelSize: appFontSizes.f_large
                        color: appColors.c_fontcolor
                        wrapMode: Text.WordWrap
                    }
                    Label
                    {
                        id:lblMeaning
                        width: parent.width
                        height: parent.height/3
                        text:""
                        font.pixelSize: appFontSizes.f_large
                        color: appColors.c_fontcolor
                        wrapMode: Text.WordWrap
                    }
                    Label
                    {
                        id:lblExample
                        width: parent.width
                        height: parent.height/3
                        text:""
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
                            getNextWord()
                        }
                        else
                        {
                            // console.log("swiped left")
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


    function doTiltAnimation(val)
    {
        if (!tiltAnimation.running)
        {
            tiltAnimation.to = val
            tiltAnimation.start()
        }
    }

    function mistakeMade()
    {
        mistakesCounter++
        getNextWord(-50)
    }

    function showDetails()
    {
        if (!flipAnimation.running)
        {
            showInfo = !showInfo
            flipAnimation.start()
        }
    }

    function getNextWord(animationVal=50)
    {

        //reset by fliping card to frontFace(word)
        if(showInfo)
            showDetails()


        doTiltAnimation(animationVal)

        backend.getNextWord(lblText.text,isThisWordModified)

        //turn flag off for next word
        isThisWordModified=false
    }

    function routeToModifyPage()
    {
        isThisWordModified=true;
        practiceTimeCom.stopTimer()
        practiceCore.m_stackView.push("../ModifyWordForm.qml",
                                          {"formType":"word",
                                          "wordId":currentWordId,
                                          "formData": currentWord,
                                          "parentName": flashcardPracticeCore})
    }

    function routeBackFromModifyPage(modifiedData)
    {
        practiceCore.m_stackView.pop()
        currentWord = modifiedData

        /*
        console.log("routeBackFromModifyPage, data=")
        for (var i = 0; i < currentWord.length; ++i)
        {
            var row = currentWord[i]
            for (var key in row)
            {
                console.log("  " + key + ": " + row[key])
            }
            console.log("---")
        }*/
        updateTextValues()
        practiceTimeCom.startTimer()
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
        lblText.text=""+getValueByKey(currentWord,"text","text")
        lblMeaning.text="Meaning: \n"+getValueByKey(currentWord,"meaning","meaning")
        lblExample.text="\nExample: \n"+getValueByKey(currentWord,"example","example")
        lblTranslate.text="\nTranslate: \n"+getValueByKey(currentWord,"translate","translate")
        currentWordId=getValueByKey(currentWord,"id","id")
    }


    Connections
    {
        target: backend
        function onWordReady(word)
        {
            currentWord=word
            updateTextValues()
        }
        function onPracticeFinished()
        {
            //finished
            practiceTimeCom.stopTimer()

            //set parent's result, and quit
            practiceCore.practiceResult = {"mistakeCount":mistakesCounter,
                                           "timeSpent":practiceTimeCom.timerString,
                                           "practiceTypeId":appPracticeTypesList["flashcardPractice"]}
            practiceCore.quitMode()
        }
    }

    Component.onCompleted:
    {
        backend.resetPractice()
        maxWordId = backend.getNextWord("firstword")

        if(maxWordId<=0)//this table doesn't have enough words
            practiceCore.quitMode(false,"this table doesn't have enough words to practice, add some word..")
        else
            proccessBar.totalValue = maxWordId

        practiceTimeCom.startTimer()
    }
}
