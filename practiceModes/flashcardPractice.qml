import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../CustomComponents"
import QtMultimedia
import "../interfaceScripts.js" as IFS

Page
{
    id: flashcardPracticeCore
    property bool showInfo:false

    property int mistakesCounter:0

    property int maxWordId: 0
    property int currentWordId:0
    property int currentWordCount: 0 //for modes like practiceOnlyStarred (word id will be random so need a logical number for processbar)


    //smart timer
    property int idleTimeCounter: 0
    property int maxIdleTime: 7


    property string practiceMode: "none" //e.g: word

    property bool practiceOnlyStarred:false
    property bool isWordStared: false

    property bool isThisWordModified: false;

    property string contentPath;
    property var currentWord:
    {
        "text": "Apple",
        "meaning": "A fruit",
        "example": "An apple a day keeps the doctor away.",
        "translate": "Elma",
        "picture": ""
    }


    CustomTimer
    {
        id:practiceTimeCom
        onEachTrigger:
        {
            if(idleTimeCounter<=maxIdleTime)
            {
                idleTimeCounter++;
                if(idleTimeCounter>=maxIdleTime)
                    pauseTimer();
            }
            // console.log(practiceTimeCom.timerString  + " idlc=" + idleTimeCounter + " max=" +maxIdleTime + " tst="+  practiceTimeCom.status())
        }
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
                topMargin:15
            }

            Row
            {
                width: implicitWidth
                height: 50
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                CustomButtonWithIcon
                {
                    id:playButton
                    setWidth:30
                    setHeight:30
                    setButtonText:"";
                    setButtonBorderColor: "transparent";
                    setButtonFontColor:appColors.c_fontcolor;
                    setButtonBackColor:"transparent"
                    setTextMagin: 5
                    setVisible: false
                    setIconHeight: 25
                    setIconWidth: 25
                    setIconSource:  appIcons.icon_play
                    onButtonClicked:
                    {
                        if(player.playing)
                        {
                            player.stop()
                        }
                        else
                        {
                            player.play()
                        }
                    }
                }

                CustomButtonWithIcon
                {
                    id:favoriteWordButton
                    setWidth:25
                    setHeight:25
                    setButtonText:"";
                    setButtonBorderColor: "transparent";
                    setButtonFontColor:appColors.c_fontcolor;
                    setButtonBackColor:"transparent"
                    setTextMagin: 5
                    setIconHeight: 20
                    setIconWidth: 20
                    setIconSource: isWordStared ? appIcons.icon_filledStar: appIcons.icon_star
                    onButtonClicked:
                    {
                        let newStatus = isWordStared?"0":"starred"
                        if(backend.setWordStatus(currentWordId, newStatus))
                        {
                            isWordStared = !isWordStared;
                            IFS.modifyWordValue(currentWord,"status",newStatus)
                        }
                    }
                }

                CustomProccessBar
                {
                    id:proccessBar
                    currentValue: practiceOnlyStarred? currentWordCount:currentWordId-1
                    setWidth: 150
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


            Rectangle
            {
                id: card
                width: parent.width * 0.8
                height: 400
                anchors.horizontalCenter: parent.horizontalCenter
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
                    Column
                    {
                        width: parent.width/1.50
                        height:parent.height
                        spacing:25
                        anchors
                        {
                            top:parent.top
                            topMargin:70
                            horizontalCenter: parent.horizontalCenter
                        }

                        AnimatedImage
                        {
                            id:cardPicture
                            width:150
                            height: status === Image.Error ? 70: 150
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Label
                        {
                            id:lblText
                            text: ""
                            width: parent.width/2
                            height:implicitHeight
                            font.pixelSize: appFontSizes.f_title
                            font.bold: true
                            color: appColors.c_fontcolor
                            anchors.horizontalCenter: parent.horizontalCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Text
                        {
                            id:lblType
                            text:""
                            width: parent.width
                            height:implicitHeight
                            visible: text.length>0 ? true : false
                            font.pixelSize:appFontSizes.f_normal
                            color:appColors.c_fontcolor
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }


                }

                Item
                {
                    id: backFace
                    width:parent.width
                    height:parent.height
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
                            if(deltaX > 0)
                                getNextWord(true) //swiped right
                            else
                                getNextWord(false) //swiped left
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
                    setIconSource: appIcons.icon_skip_white
                    setIconFlipHorizontal: true
                    setIconWidth: 35
                    setIconHeight: 35
                    setButtonsBorderWidth: 0
                    setRadius: 50
                    setWidth: 50
                    setHeight:50
                    onButtonClicked:
                    {
                        getNextWord(false)
                    }
                }

                CustomButtonWithIcon
                {
                    setButtonText:""
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setIconSource: appIcons.icon_turn_white
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
                    setIconSource: appIcons.icon_skip_white
                    setIconWidth: 35
                    setIconHeight: 35
                    setRadius: 50
                    setWidth: 50
                    setHeight:50
                    onButtonClicked:
                    {
                        getNextWord(true)
                    }
                }
            }
        }
    }


    MediaPlayer
    {
        id: player
        audioOutput: audioOut
        onPlayingChanged:
        {
            if(player.playing)
            {
                playButton.setIconSource= appIcons.icon_play
            }
            else
            {
                playButton.setIconSource= appIcons.icon_pause
            }
        }
    }

    AudioOutput {
        id: audioOut
        volume: 1.0  // Max volume
    }


    function doTiltAnimation(val)
    {
        if (!tiltAnimation.running)
        {
            tiltAnimation.to = val
            tiltAnimation.start()
        }
    }

    // function mistakeMade()
    // {
    //     mistakesCounter++
    //     getNextWord(-50)
    // }

    function showDetails()
    {
        //set user status active for smart timer
        idleTimeCounter=0;
        if(!practiceTimeCom.status())
            practiceTimeCom.resumeTimer()


        if (!flipAnimation.running)
        {
            showInfo = !showInfo
            flipAnimation.start()
        }
    }

    function getNextWord(isForward)
    {
        //set user status active for smart timer
        idleTimeCounter=0;
        if(!practiceTimeCom.status())
            practiceTimeCom.resumeTimer()


        var animationVal;
        if(isForward)
        {
            animationVal=50
            currentWordCount++;
        }
        else//backward
        {
            animationVal=-50
            if(currentWordCount>0)
                currentWordCount--;
            else
                currentWordCount=0

        }

        //reset by fliping card to frontFace(word)
        if(showInfo)
            showDetails()


        doTiltAnimation(animationVal)

        backend.getWordNoInputCheck(practiceOnlyStarred?"starred":"all",
                                    isForward);

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

    function routeBackFromModifyPage(modifiedData=-1)
    {
        practiceCore.m_stackView.pop()

        if(modifiedData!==-1)//means modify canceled by user
        {
            currentWord = modifiedData
            updateTextValues()
        }


        /*console.log("routeBackFromModifyPage, data=")
        for (var i = 0; i < currentWord.length; ++i)
        {
            var row = currentWord[i]
            for (var key in row)
                console.log("  " + key + ": " + row[key])
            console.log("---")
        }*/
        practiceTimeCom.resumeTimer()
    }


    function updateTextValues()
    {
        //data setup
        var id = IFS.getValueByKey(currentWord,"id","id")
        lblText.text=""+IFS.getValueByKey(currentWord,"text")
        lblType.text="["+IFS.getValueByKey(currentWord,"type")+"]"
        lblMeaning.text="Meaning:\n"+IFS.getValueByKey(currentWord,"meaning",)
        lblExample.text="Example:\n"+IFS.getValueByKey(currentWord,"example")
        isWordStared = IFS.getValueByKey(currentWord,"status")==="starred" ? true : false;
        lblTranslate.text="\nTranslate:\n"+IFS.getValueByKey(currentWord,"translate")
        currentWordId=id;


        //image setup
        var picPath = "file://"+contentPath+IFS.getValueByKey(currentWord,"picture");
        cardPicture.source= picPath;
        //if picture is animated one play it
        if (picPath.split('.').pop().toLowerCase() === "gif")
            cardPicture.playing=true


        //audio setup
        var audioName = IFS.getValueByKey(currentWord,"audio");
        var audioPath = "file://"+contentPath+audioName;
        if(audioName.length>1)
        {
            player.source = audioPath;
            if(appSettings.autoPlayAudioOnPractice)
                player.play()
        }
        else
        {
            if(appSettings.wheterLocalVoiceNotExistsGetFromTTS)
            {
                if(appSettings.saveTTSvoice)
                {
                    backend.googleTTS(lblText.text,currentWordId);
                }
                else
                    console.log("just play from online TTS")
            }
            else
                console.log("wheterLocalVoiceNotExistsGetFromTTS is off.");
        }



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
        function onTtsDone(result,fileName)
        {
            if(result)
            {
                player.source="file://"+contentPath+fileName;
                if(appSettings.autoPlayAudioOnPractice)
                    player.play()

                playButton.setVisible=true
            }
            else
            {
                console.log("faild to load from tts")
                playButton.setVisible=false
            }
        }
    }

    Component.onCompleted:
    {
        backend.resetPractice()

        contentPath = backend.getContentPath()

        //to fetch first word and get maxium number of content on table
        if(practiceOnlyStarred)
            maxWordId = backend.getCountOfWordsStatusTable("starred");
        else
            maxWordId = backend.getMaxIdWordTable();


        backend.getWordNoInputCheck(practiceOnlyStarred?"starred":"all",
                                    true);


        if(maxWordId<=0)//this table doesn't have enough words
            practiceCore.quitMode(false,"this table doesn't have enough words to practice, add some word..")
        else
            proccessBar.totalValue = maxWordId

        practiceTimeCom.startTimer()

    }
}
