import QtQuick
import QtQuick.Controls
import "../CustomComponents"
import QtMultimedia
import "../interfaceScripts.js" as IFS

Page
{
    id:typePracticeCore
    //this will set from parent before start.
    property int selectedTableId:-1;





    property int mistakesCounter: 0;
    property int currentIndex: 0;
    property int currentWordCount: 0 //for modes like practiceOnlyStarred (word id will be random so need a logical number for processbar)
    property int maxIndex: 100;


    property bool isWordStared: false

    property var practiceData: []

    property var tableItems: []
    property var tableHeaders: []
    property int currentTypingItem:0




    //page items visitiblity and customizable
    property bool showHeader:true
    property bool showItem:true
    property bool showTranslate:false

    property bool practiceOnlyStarred:false

    property bool blurSomeCharectersOfItem:false
    property string blurFraction:"1/2"// so 50% of word would replace by *

    property bool showIndex:false
    property string postfixIndex: "x"
    property int indexIncrease:1


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
                            // modifyWordValue(practiceData,"status",newStatus) //for modify page
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
                    setWidth:30
                    setHeight:30
                    setButtonText:"";
                    setButtonBorderColor: "transparent";
                    setButtonFontColor:appColors.c_fontcolor;
                    setButtonBackColor:"transparent"
                    setTextMagin: 5
                    setIconHeight: 25
                    setIconWidth: 25
                    setIconSource:  appIcons.icon_eye
                    onButtonClicked:
                    {
                        popupMessage.open()
                    }
                }

            }
            Label
            {
                id:w_header
                text:""
                width: parent.width
                height:implicitHeight
                font.pixelSize:appFontSizes.f_large
                color:appColors.c_fontcolor
                visible: text.length> 0 ? showHeader : false
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            Label
            {
                id:w_text
                text:""
                width: parent.width
                height:implicitHeight
                font.pixelSize:appFontSizes.f_title
                font.bold: true
                visible: text.length> 0 ? showItem : false
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
                    id:w_translate
                    text:""
                    visible: text.length> 0 ? showTranslate : false
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
        setWidth: parent.width/1.50
        setHeight: 450
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
                        maxIndex = backend.getCountOfWordsStatusTable("starred")*tableHeaders.length;
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
                setBoxIconSource: appIcons.icon_check
                setStatus: blurSomeCharectersOfItem
                onButtonClicked:
                {
                    blurSomeCharectersOfItem=setStatus
                    if(blurSomeCharectersOfItem)
                        w_text.text= IFS.blurRandomChars(tableItems[currentTypingItem],blurFraction)
                    else
                        w_text.text= tableItems[currentTypingItem]
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
                setCheckBoxText:"Show Header?"
                setBoxBorderWidth:3
                setBoxIconSource: appIcons.icon_check
                setStatus: showHeader
                onButtonClicked:
                {
                    showHeader=setStatus
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
                setCheckBoxText:"Show index?"
                setBoxBorderWidth:3
                setBoxIconSource: appIcons.icon_check
                setStatus: showIndex
                onButtonClicked:
                {
                    showIndex=setStatus
                }
            }
            CustomTextInput
            {
                id:newNameTable
                setWidth: parent.width/1.25
                setHeight: 50
                setBgColor: appColors.c_bgColor_textinput
                setBordercolor: appColors.c_borderColor_textinput
                setBorderWidth:2
                setFontSize:appFontSizes.f_textInput
                setFontColor: appColors.c_fontColor_textinput
                setRadius:10
                theText:postfixIndex
                setErrorPosfix: ""
                setErrorPrefix: ""
                setTitleText:"postfix index:"
                onTheTextAccepted:
                {
                    postfixIndex=theText
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

    function getNextWord(isForward=true)
    {
        if(text_input.theText.length>=1)
        {
            if(isForward)
            {
                currentWordCount++;

                //state check
                var lenItems = tableItems.length-1
                if(currentTypingItem<=lenItems)
                {
                    if(text_input.theText===tableItems[currentTypingItem])
                    {
                        currentTypingItem++;
                        if(currentTypingItem>lenItems)
                        {
                            backend.getWordNoInputCheck(practiceOnlyStarred?"starred":"all",
                                                        isForward);
                        }
                        else
                        {
                            if(blurSomeCharectersOfItem)
                                w_text.text= blurRandomChars(tableItems[currentTypingItem],blurFraction)
                            else
                                w_text.text= tableItems[currentTypingItem]


                            var prefix = showIndex ? ""+(currentIndex+indexIncrease) + ""+postfixIndex : ""
                            w_header.text = prefix + tableHeaders[currentTypingItem]
                        }
                        text_input.clear()
                    }
                    else
                        mistakeMade()
                }
            }
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
        backend.resetPractice();
        practiceTimeCom.startTimer()


        //get table headers
        backend.getCustomTableHeaders(selectedTableId);



        //get count words
        var totalWords;
        if(practiceOnlyStarred)
            totalWords = backend.getCountOfWordsStatusTable("starred")*tableHeaders.length;
        else
            totalWords = backend.getMaxIdWordTable();

        //get word
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


    function updateTextValues()
    {
        //practice data setup
        currentIndex=IFS.getValueByKey(practiceData,"id")
        for(var i=0; i<=9; i++)
        {
            var value=IFS.getValueByKey(practiceData,"item"+(i+1))

            if(i<tableHeaders.length)
            {
                tableItems.push(value)
            }
            else
            {
                //header not defined so we will ignore data.
            }


        }

        if(blurSomeCharectersOfItem)
            w_text.text= blurRandomChars(tableItems[currentTypingItem],blurFraction)
        else
            w_text.text= tableItems[currentTypingItem] //currentTypingItem=0 first item

        var prefix = showIndex ? ""+(currentIndex+indexIncrease) + ""+postfixIndex : ""
        w_header.text = prefix + tableHeaders[currentTypingItem]

        w_translate.text=IFS.getValueByKey(practiceData,"translate")

        isWordStared=IFS.getValueByKey(practiceData,"status")==="starred" ? true : false;
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
            //reset values for next word
            currentTypingItem=0
            tableItems=[]

            practiceData=word
            // console.log("onWordReady =", JSON.stringify(practiceData));

            updateTextValues()

            text_input.clear()
        }
        function onWordIsIncorrect(correctStatus)
        {
            if(correctStatus==="incorrect")
                mistakeMade();
        }

        function onGetCustomTableHeadersResult(result)
        {
            if(result.length>1)
            {
                // Split the string by comma
                var parts = result.split(",")

                // Filter out empty items (like after the last comma)
                tableHeaders = parts.filter(function(item)
                {
                    return item.trim() !== ""
                })

                // console.log("Table headers:", tableHeaders)
            }
            else
            {
                //handle empty headers

            }

            // console.log("get customtable header reuslt= ", result)
        }
    }

    Component.onCompleted:
    {
        startPractice()
    }
}
