import QtQuick
import QtQuick.Controls
import "../CustomComponents"
import QtMultimedia
import "../interfaceScripts.js" as IFS

Page
{
    id:typePracticeCore
    //this will set from parent before start.
    property string practiceMode: "none" //word


    //settings
    property bool practiceOnlyStarred:false
    property bool showTranslate:true
    property bool blurSomeCharectersOfItem:false
    property string blurFraction: "1/2"
    property bool showType:true;
    property bool showItem:true;
    property bool showExample:true
    property bool showMeaning:true
    property bool showImage:true
    property real voiceVolume:1.0
    property bool autoPlayVoice:appSettings.autoPlayAudioOnPractice


    //smart timer
    property int idleTimeCounter: 0
    property int maxIdleTime: 7


    property int mistakesCounter: 0;
    property int currentIndex: 0;
    property int currentWordCount: -1 //for modes like practiceOnlyStarred (word id will be random so need a logical number for processbar)
    property int maxIndex: 100;


    property bool pictureIsAnimated:false;
    property string contentPath;


    property bool isWordStared: false
    property bool isThisWordModified: false;

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
                    setIconHeight: 25
                    setVisible: false
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
                        if(backend.setWordStatus(currentIndex, newStatus))
                        {
                            isWordStared = !isWordStared;
                            IFS.modifyWordValue(practiceData,"status",newStatus)
                        }


                    }
                }
                CustomProccessBar
                {
                    id:proccessBar
                    currentValue: practiceOnlyStarred? currentWordCount:currentIndex-1
                    totalValue: maxIndex
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
                    id:openLocalSettings
                    setWidth:30
                    setHeight:30
                    setButtonText:"";
                    setButtonBorderColor: "transparent";
                    setButtonFontColor:appColors.c_fontcolor;
                    setButtonBackColor:"transparent"
                    setTextMagin: 5
                    setIconHeight: 25
                    setIconWidth: 25
                    setIconSource:appIcons.icon_eye
                    onButtonClicked:
                    {
                        popupMessage.open()
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

            AnimatedImage
            {
                id:wordPicture
                width:150
                height:150
                playing: pictureIsAnimated;
                visible: showImage
                anchors.horizontalCenter: parent.horizontalCenter
                onStatusChanged:
                {
                    if (status === Image.Error)
                    {
                        console.warn("Image failed to load:", source);
                        visible=false
                    }
                    else
                        visible=true
                }
            }
            Label
            {
                id:w_text
                text:""
                width: parent.width
                height:implicitHeight
                font.pixelSize:appFontSizes.f_title
                font.bold: true
                color:appColors.c_fontcolor
                visible: text.length>0 ? showItem : false
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Column
            {
                id:columnPractice
                width: parent.width
                height: parent.height-100
                spacing:25

                Text
                {
                    id:w_type
                    text:""
                    width: parent.width
                    height:implicitHeight
                    visible: text.length>0 ? showType : false
                    font.pixelSize:appFontSizes.f_normal
                    color:appColors.c_fontcolor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
                Label
                {
                    id:w_meaning
                    text:""
                    width: parent.width
                    height:implicitHeight
                    visible: text.length>0 ? showMeaning : false
                    font.pixelSize:appFontSizes.f_large
                    color:appColors.c_fontcolor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
                Label
                {
                    id:w_example
                    text:""
                    visible: text.length>0 ? showExample : false
                    width: parent.width
                    height: implicitHeight
                    font.pixelSize:appFontSizes.f_large
                    color:appColors.c_fontcolor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }

                Label
                {
                    id:w_translate
                    text:""
                    visible: text.length>0 ? showTranslate : false
                    width: parent.width
                    height: implicitHeight
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
                            getNextWord()
                        }
                        onTheTextChanged:
                        {
                            //set user status active for smart timer
                            idleTimeCounter=0;
                            if(!practiceTimeCom.status())
                                practiceTimeCom.resumeTimer()
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
                            getNextWord()
                        }
                    }

                }

            }



        }




        CustomTimer
        {
            id:practiceTimeCom
            onWhenPaused:
            {
                //to pause animatedImage when we are on ModifyWord
                if(pictureIsAnimated)
                {
                    console.log("pausing anbimated image...")
                    wordPicture.playing=false
                }
            }
            onWhenResumed:
            {
                //to resume when we are back from ModifyWord
                if(pictureIsAnimated)
                {
                    console.log("resuming animatedimage...")
                    wordPicture.playing=true
                }
            }
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


        MediaPlayer
        {
            id: player
            audioOutput: audioOut
            onPlayingChanged:
            {
                if(player.playing)
                {
                    playButton.setIconSource= appIcons.icon_pause
                }
                else
                {
                    playButton.setIconSource= appIcons.icon_play
                }
            }
        }

        AudioOutput {
            id: audioOut
            volume: voiceVolume
        }




    }


    CustomPopupMessage
    {
        id:popupMessage
        setDefaultText: ""
        setFailColor: appColors.c_bgPopupContentFailed
        setSuccessColor:appColors.c_bgPopupContentSuccess
        setBgContent: appColors.c_bgPopupContentDefault
        setTextFontSize: appFontSizes.f_normal
        setTextColor:  appColors.c_fontcolor
        setBgColorPopup: appColors.c_background
        setBgOpacityPopup: 0.5
        setWidth: parent.width/1.50
        setHeight: 550
        Column
        {
            anchors.fill: parent
            spacing:5
            CustomCheckBox
            {
                setWidth: parent.width/2
                setHeight: 50
                setBoxCheckedBorderColor:appColors.c_buttonBgColor
                setBoxUncheckedBorderColor:appColors.c_buttonBgColor
                setBoxCheckedBackColor:appColors.c_buttonBgColor
                setCheckBoxFontColor:appColors.c_fontcolor
                setCheckBoxFontsize:appFontSizes.f_normal
                setBold:true
                setWidthBox:25
                setHeightBox: 25
                setCheckBoxText:"Only Starred?"
                setBoxBorderWidth:3
                setBoxIconSource: appIcons.icon_check
                setStatus: practiceOnlyStarred
                onButtonClicked:
                {
                    practiceOnlyStarred=setStatus
                    if(practiceOnlyStarred)
                        maxIndex = backend.getCountOfWordsStatusTable("starred");
                    else
                        maxIndex = backend.getMaxIdWordTable();
                }
            }

            CustomCheckBox
            {
                setWidth: parent.width/2
                setHeight: 50
                setBoxCheckedBorderColor:appColors.c_buttonBgColor
                setBoxUncheckedBorderColor:appColors.c_buttonBgColor
                setBoxCheckedBackColor:appColors.c_buttonBgColor
                setCheckBoxFontColor:appColors.c_fontcolor
                setCheckBoxFontsize:appFontSizes.f_normal
                setBold:true
                setWidthBox:25
                setHeightBox: 25
                setCheckBoxText:"Blur Item?"
                setBoxBorderWidth:3
                // anchors.horizontalCenter: parent.horizontalCenter
                setBoxIconSource: appIcons.icon_check
                setStatus: blurSomeCharectersOfItem
                onButtonClicked:
                {
                    blurSomeCharectersOfItem=setStatus
                    if(blurSomeCharectersOfItem)
                        w_text.text= IFS.blurRandomChars(IFS.getValueByKey(practiceData,"text"),blurFraction)

                    else
                        w_text.text= IFS.getValueByKey(practiceData,"text")
                }
            }
            CustomCheckBox
            {
                setWidth: parent.width/2
                setHeight: 50
                setBoxCheckedBorderColor:appColors.c_buttonBgColor
                setBoxUncheckedBorderColor:appColors.c_buttonBgColor
                setBoxCheckedBackColor:appColors.c_buttonBgColor
                setCheckBoxFontColor:appColors.c_fontcolor
                setCheckBoxFontsize:appFontSizes.f_normal
                setBold:true
                setWidthBox:25
                setHeightBox: 25
                setCheckBoxText:"Show Type? [v].."
                setBoxBorderWidth:3
                // anchors.horizontalCenter: parent.horizontalCenter
                setBoxIconSource: appIcons.icon_check
                setStatus: showType
                onButtonClicked:
                {
                    showType=setStatus
                    console.log("showType=",showType)
                }
            }
            CustomCheckBox
            {
                setWidth: parent.width/2
                setHeight: 50
                setBoxCheckedBorderColor:appColors.c_buttonBgColor
                setBoxUncheckedBorderColor:appColors.c_buttonBgColor
                setBoxCheckedBackColor:appColors.c_buttonBgColor
                setCheckBoxFontColor:appColors.c_fontcolor
                setCheckBoxFontsize:appFontSizes.f_normal
                setBold:true
                setWidthBox:25
                setHeightBox: 25
                setCheckBoxText:"Show Item?"
                setBoxBorderWidth:3
                // anchors.horizontalCenter: parent.horizontalCenter
                setBoxIconSource: appIcons.icon_check
                setStatus: showItem
                onButtonClicked:
                {
                    showItem=setStatus
                }
            }
            CustomCheckBox
            {
                setWidth: parent.width/2
                setHeight: 50
                setBoxCheckedBorderColor:appColors.c_buttonBgColor
                setBoxUncheckedBorderColor:appColors.c_buttonBgColor
                setBoxCheckedBackColor:appColors.c_buttonBgColor
                setCheckBoxFontColor:appColors.c_fontcolor
                setCheckBoxFontsize:appFontSizes.f_normal
                setBold:true
                setWidthBox:25
                setHeightBox: 25
                setCheckBoxText:"Show Translate?"
                setBoxBorderWidth:3
                // anchors.horizontalCenter: parent.horizontalCenter
                setBoxIconSource: appIcons.icon_check
                setStatus: showTranslate
                onButtonClicked:
                {
                    showTranslate=setStatus
                }
            }
            CustomCheckBox
            {
                setWidth: parent.width/2
                setHeight: 50
                setBoxCheckedBorderColor:appColors.c_buttonBgColor
                setBoxUncheckedBorderColor:appColors.c_buttonBgColor
                setBoxCheckedBackColor:appColors.c_buttonBgColor
                setCheckBoxFontColor:appColors.c_fontcolor
                setCheckBoxFontsize:appFontSizes.f_normal
                setBold:true
                setWidthBox:25
                setHeightBox: 25
                setCheckBoxText:"Show Example?"
                setBoxBorderWidth:3
                // anchors.horizontalCenter: parent.horizontalCenter
                setBoxIconSource: appIcons.icon_check
                setStatus: showExample
                onButtonClicked:
                {
                    showExample=setStatus
                }
            }
            CustomCheckBox
            {
                setWidth: parent.width/2
                setHeight: 50
                setBoxCheckedBorderColor:appColors.c_buttonBgColor
                setBoxUncheckedBorderColor:appColors.c_buttonBgColor
                setBoxCheckedBackColor:appColors.c_buttonBgColor
                setCheckBoxFontColor:appColors.c_fontcolor
                setCheckBoxFontsize:appFontSizes.f_normal
                setBold:true
                setWidthBox:25
                setHeightBox: 25
                setCheckBoxText:"Show Meaning?"
                setBoxBorderWidth:3
                // anchors.horizontalCenter: parent.horizontalCenter
                setBoxIconSource: appIcons.icon_check
                setStatus: showMeaning
                onButtonClicked:
                {
                    showMeaning=setStatus
                }
            }
            CustomCheckBox
            {
                setWidth: parent.width/2
                setHeight: 50
                setBoxCheckedBorderColor:appColors.c_buttonBgColor
                setBoxUncheckedBorderColor:appColors.c_buttonBgColor
                setBoxCheckedBackColor:appColors.c_buttonBgColor
                setCheckBoxFontColor:appColors.c_fontcolor
                setCheckBoxFontsize:appFontSizes.f_normal
                setBold:true
                setWidthBox:25
                setHeightBox: 25
                setCheckBoxText:"Play Voice?"
                setBoxBorderWidth:3
                // anchors.horizontalCenter: parent.horizontalCenter
                setBoxIconSource: appIcons.icon_check
                setStatus: autoPlayVoice
                onButtonClicked:
                {
                    autoPlayVoice=setStatus
                }
            }
            CustomCheckBox
            {
                setWidth: parent.width/2
                setHeight: 50
                setBoxCheckedBorderColor:appColors.c_buttonBgColor
                setBoxUncheckedBorderColor:appColors.c_buttonBgColor
                setBoxCheckedBackColor:appColors.c_buttonBgColor
                setCheckBoxFontColor:appColors.c_fontcolor
                setCheckBoxFontsize:appFontSizes.f_normal
                setBold:true
                setWidthBox:25
                setHeightBox: 25
                setCheckBoxText:"Show Image?"
                setBoxBorderWidth:3
                // anchors.horizontalCenter: parent.horizontalCenter
                setBoxIconSource: appIcons.icon_check
                setStatus: showImage
                onButtonClicked:
                {
                    showImage=setStatus
                }
            }
            CustomButton
            {
                id:buttonOkPopup
                setButtonText:"done";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 70
                setHeight:50
                onButtonClicked:
                {
                    popupMessage.close()
                }
            }
        }
    }




    function mistakeMade()
    {
        mistakesCounter++;
        text_input.invalidInput("incorrect value");
    }

    function getNextWord()
    {
        if(text_input.theText.length>=1)
        {
            backend.getNextWord(text_input.theText, isThisWordModified, practiceOnlyStarred?"starred":"all")

            //turn flag off for next word
            isThisWordModified=false
        }
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
        contentPath = backend.getContentPath()


        var totalWords;
        //to fetch first word and get maxium number of content on table
        if(practiceOnlyStarred)
            totalWords = backend.getCountOfWordsStatusTable("starred");
        else
            totalWords = backend.getMaxIdWordTable();


        backend.getWordNoInputCheck(practiceOnlyStarred?"starred":"all",
                                    true);

        if(totalWords<=0)
        {
            //this table doesn't have enough words
            practiceCore.quitMode(false,"this table doesn't have enough words to practice, add some word..")
        }
        else
            maxIndex = totalWords
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
            practiceData = modifiedData
            updateTextValues()
        }


        /*console.log("typepractice routeBackFromModifyPage, data=")
        for (var i = 0; i < practiceData.length; ++i)
        {
            var row = practiceData[i]
            for (var key in row)
                console.log("  " + key + ": " + row[key])
            console.log("---")
        }*/

        practiceTimeCom.resumeTimer()
    }


    function updateTextValues()
    {
        //practice data setup
        if(blurSomeCharectersOfItem)
            w_text.text= IFS.blurRandomChars(IFS.getValueByKey(practiceData,"text"),blurFraction)
        else
            w_text.text= IFS.getValueByKey(practiceData,"text")



        w_type.text= "["+IFS.getValueByKey(practiceData,"type")+"]"
        w_meaning.text=IFS.getValueByKey(practiceData,"meaning")
        w_example.text=IFS.getValueByKey(practiceData,"example")
        w_translate.text=IFS.getValueByKey(practiceData,"translate")
        currentIndex=IFS.getValueByKey(practiceData,"id")
        isWordStared=IFS.getValueByKey(practiceData,"status")==="starred" ? true : false;


        //image setup
        var picPath = "file://"+contentPath+IFS.getValueByKey(practiceData,"picture");
        wordPicture.source= picPath;
        //if picture is animated one play it
        pictureIsAnimated = picPath.split('.').pop().toLowerCase()==="gif"? true : false


        //audio setup
        // var audioName = IFS.getValueByKey(practiceData,"audio"); //no need. we dont save audio name so just load that index.mp3
        var audioPath = contentPath+currentIndex;
        // console.log("audioPath=",audioPath)
        if(backend.isFileAvailable(contentPath+currentIndex+".wav"))
        {
            // console.log("tts wav found")
            player.source = "file://"+audioPath+".wav";
            if(autoPlayVoice)
                player.play()
            playButton.setVisible=true
        }
        else if(backend.isFileAvailable(contentPath+currentIndex+".mp3"))
        {
            // console.log("tts mp3 found")
            player.source = "file://"+audioPath+".mp3";
            if(autoPlayVoice)
                player.play()
            playButton.setVisible=true
        }
        else
        {
            // console.log("tts not found")
            if(appSettings.wheterLocalVoiceNotExistsGetFromTTS)
            {
                if(appSettings.saveTTSvoice)
                {
                    backend.tts(w_text.text,currentIndex);
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
        function onPracticeFinished()
        {
            quitPractice()
        }

        function onWordReady(word)
        {
            practiceData=word
            // console.log("onWordRead =", JSON.stringify(practiceData));

            updateTextValues()
            currentWordCount++;
            text_input.clear()
        }
        function onWordIsIncorrect(correctStatus)
        {
            if(correctStatus==="incorrect")
                mistakeMade();
        }
        function onTtsDone(result,voicePath)
        {
            if(result)
            {
                player.source="file://"+voicePath;
                if(autoPlayVoice)
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
        startPractice()
    }
}
