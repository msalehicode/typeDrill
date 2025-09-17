import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../CustomComponents"


Page {
    id: flashcardPracticeCore
    width: 400
    height: 600

    property bool showInfo:false

    property int mistakesCounter:0

    property int maxWordId: 0
    property int currentWordId:0

    property string practiceMode: "none"

    property bool isThisWordModified: false;

    property var currentWord:
    {
        "text": "Apple",
        "meaning": "A fruit",
        "example": "An apple a day keeps the doctor away.",
        "translate": "Elma"
    }


    CustomTimer
    {
        id:practiceTimeCom
    }

    Rectangle
    {
        anchors.fill: parent
        color:appColors.c_background

        Column
        {
            width:parent.width
            height:parent.height
            spacing:40
            anchors
            {
                top:parent.top
                topMargin:5
            }

            Row
            {
                width: parent.width
                height: 70
                spacing: 10
                CustomProccessBar
                {
                    id:proccessBar
                    currentValue:currentWordId-1
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

            }


            Rectangle
            {
                id: card
                width: parent.width * 0.8
                height: 400//parent.height * 0.5
                anchors.horizontalCenter: parent.horizontalCenter
                // anchors.centerIn: parent
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
                        width: parent.width/2
                        height:parent.height/2
                        font.pixelSize: appFontSizes.f_title
                        font.bold: true
                        color: appColors.c_fontcolor
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                Item
                {
                    id: backFace
                    width:parent.width
                    height:parent.height
                    // anchors.centerIn: parent
                    visible: showInfo && !flipAnimation.running
                    Column
                    {
                        anchors.fill: parent
                        spacing: 5
                        Label
                        {
                            id:lblTranslate
                            width: parent.width
                            visible: text.length>0 ? true : false
                            height: 120
                            text:""
                            font.pixelSize: appFontSizes.f_large
                            color: appColors.c_fontcolor
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label
                        {
                            id:lblMeaning
                            width: parent.width
                            height: 120
                            visible: text.length>0 ? true : false
                            text:""
                            font.pixelSize: appFontSizes.f_large
                            color: appColors.c_fontcolor
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Label
                        {
                            id:lblExample
                            width: parent.width
                            height: 120
                            visible: text.length>0 ? true : false
                            text:""
                            font.pixelSize: appFontSizes.f_large
                            color: appColors.c_fontcolor
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
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


            Row
            {
                width: parent.width/2
                height: 50
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                CustomButtonWithIcon
                {
                    setButtonText:"";
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setIconSource: appIcons.icon_skip
                    setIconFlipHorizontal: true
                    setIconWidth: 35
                    setIconHeight: 35
                    setButtonsBorderWidth: 0
                    setRadius: 50
                    setWidth: 50
                    setHeight:50
                    onButtonClicked:
                    {
                        mistakeMade()
                    }
                }

                CustomButtonWithIcon
                {
                    setButtonText:""
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setIconSource: appIcons.icon_turn
                    setIconWidth: 35
                    setIconHeight: 35
                    setButtonsBorderWidth: 0
                    setRadius: 50
                    setWidth: 50
                    setHeight:50
                    onButtonClicked:
                    {
                        showDetails()
                    }
                }

                CustomButtonWithIcon
                {
                    setButtonText:"";
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setButtonsBorderWidth: 0
                    setIconSource: appIcons.icon_skip
                    setIconWidth: 35
                    setIconHeight: 35
                    setRadius: 50
                    setWidth: 50
                    setHeight:50
                    onButtonClicked:
                    {
                        getNextWord()
                    }
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

        backend.getNextWord(getValueByKey(currentWord,"text","verb"),isThisWordModified)

        //turn flag off for next word
        isThisWordModified=false
    }

    function routeToModifyPage()
    {
        isThisWordModified=true;
        practiceTimeCom.pauseTimer()
        practiceCore.m_stackView.push("../forms/ModifyWordForm.qml",
                                          {"formType":practiceMode,
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
        if(practiceMode==="word")
        {
            lblText.text=""+getValueByKey(currentWord,"text","text")
            lblMeaning.text="Meaning:\n"+getValueByKey(currentWord,"meaning","meaning")
            lblExample.text="Example:\n"+getValueByKey(currentWord,"example","example")
        }
        else if(practiceMode==="verb")
        {
            lblText.text=""+getValueByKey(currentWord,"verb","verb")
            lblText.text+="\n\n"+getValueByKey(currentWord,"past","past")
            lblText.text+="\n\n"+getValueByKey(currentWord,"past_perfect","past_perfect")
        }

        lblTranslate.text="\nTranslate:\n"+getValueByKey(currentWord,"translate","translate")
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
