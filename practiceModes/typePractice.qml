import QtQuick
import QtQuick.Controls
import "../CustomComponents"
import QtMultimedia

Page
{
    id:typePracticeCore
    //this will set from parent before start.
    property string practiceMode: "none" //word
    property bool practiceOnlyStarred:false


    //a flag to hide meaining/example/... except word
    property bool hideAllExceptFirstItem: false;

    property int mistakesCounter: 0;
    property int currentIndex: 0;
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
                        if(audio.playing)
                        {
                            audio.play()
                            playButton.setIconSource= appIcons.icon_pause
                        }
                        else
                        {
                            audio.stop()
                            playButton.setIconSource= appIcons.icon_play
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
                            modifyWordValue(practiceData,"status",newStatus)
                        }


                    }
                }
                CustomProccessBar
                {
                    id:proccessBar
                    currentValue:currentIndex-1
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

            AnimatedImage
            {
                id:wordPicture
                width:150
                height:150
                playing: pictureIsAnimated;
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
                    text:"[type]"
                    width: parent.width
                    height:implicitHeight
                    visible: hideAllExceptFirstItem ? false : text.length>0 ? true : false;
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
                    visible: hideAllExceptFirstItem ? false : text.length>0 ? true : false;
                    font.pixelSize:appFontSizes.f_large
                    color:appColors.c_fontcolor
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
                Label
                {
                    id:w_example
                    text:""
                    visible: hideAllExceptFirstItem ? false : text.length>0 ? true : false;
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
                    visible: hideAllExceptFirstItem ? false : text.length>0 ? true : false;
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
        }

        SoundEffect
        {
            id: audio
            volume: 1.0
            onStatusChanged:
            {
                if (audio.status === SoundEffect.Ready)
                {
                    playButton.setVisible=true
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
        }
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
        contentPath = backend.getContentPath()

        //to fetch first word and get maxium number of content on table
        var totalWords = backend.getMaxIdWordTable();
        backend.getNextWordNoInputCheck(practiceOnlyStarred?"starred":"all")


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

    function getValueByKey(dataList, firstKey)
    {
        if (!dataList || dataList.length === 0)
            return "";

        for (var i = 0; i < dataList.length; ++i)
        {
            var row = dataList[i];
            if (firstKey in row)
                return row[firstKey];
        }
        return "";
    }

    function modifyWordValue(data,key,value)
    {
        for (var i = 0; i < data.length; ++i)
        {
            var row = data[i];
            if (key in row)
                row[key]=value;
        }
    }

    function updateTextValues()
    {

        //image setup
        var picPath = "file://"+contentPath+getValueByKey(practiceData,"picture");
        wordPicture.source= picPath;
        //if picture is animated one play it
        pictureIsAnimated = picPath.split('.').pop().toLowerCase()==="gif"? true : false


        //audio setup
        var audioPath = "file://"+contentPath+getValueByKey(practiceData,"audio");
        audio.source = audioPath;
        if(appSettings.autoPlayAudioOnPractice)
            audio.play()

        //other data setup
        w_text.text=getValueByKey(practiceData,"text")
        w_type.text= "["+getValueByKey(practiceData,"type")+"]"
        w_meaning.text=getValueByKey(practiceData,"meaning")
        w_example.text=getValueByKey(practiceData,"example")
        w_translate.text=getValueByKey(practiceData,"translate")
        currentIndex=getValueByKey(practiceData,"id")
        isWordStared=getValueByKey(practiceData,"status")==="starred" ? true : false;
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

            text_input.clear()
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
