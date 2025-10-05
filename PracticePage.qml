import QtQuick
import QtQuick.Controls
import "CustomComponents"

Page
{
    id:practiceCore
    //to pass mainStackView from parent
    property var m_stackView: mainStackView

    //fill up outside/before pushing to mainStackView
    property string tableType: "none"


    //each practice can fill these values to report their result

    //fill in order by targetPractice(e.g: by typePractice.qml):
    //practiceTypeId codes: (typePractice:1, flashcardPractice:2)
    property var practiceResult: {"mistakeCount":"15", "timeSpent":"10:00:20", "practiceTypeId":1} 

    header: Rectangle //this will appear on all practice pages
    {
        width: parent.width
        height: 60
        color: appColors.c_headerBg
        Label
        {
            id:headerText
            text:"Choose Practice"
            horizontalAlignment: Text.AlignHCenter
            color: appColors.c_fontcolor
            font.pixelSize: appFontSizes.f_normal
            font.bold:true
            anchors
            {
                verticalCenter:parent.verticalCenter
                left:parent.left
                leftMargin: 50
            }
        }


        CustomButtonWithIcon
        {
            id:backToPracticePage
            setButtonText:"";
            setIconSource: appIcons.icon_back
            setButtonBorderColor: "transparent"
            setButtonBackColor: "transparent"
            setButtonFontColor: "transparent"
            setIconWidth: 20
            setIconHeight: 20
            setButtonsBorderWidth: 0
            setRadius: 50
            setWidth: 50
            setHeight:50
            anchors
            {
                left: parent.left
                leftMargin:5
                top:parent.top
                topMargin:5
            }
            onButtonClicked:
            {
                //if user is on result stage: hide result stage then go to select stage.
                if(resultBase.visible)
                {
                    resultBase.visible=false
                    quitMode(false)
                }
                //so we are not in stage result or practiceMode, can quit practicePage
                else if(practiceLoader.source.toString()==="")
                {
                    m_stackView.pop()
                }
                else //go to select stage.
                {
                    headerText.text = "Choose Practice"
                    quitMode(false)
                }

            }
        }


    }

    Loader
    {
        id:practiceLoader
        anchors.fill: parent
        visible: false
        source:""
    }


    Rectangle
    {
        id:selectPracticeBase
        anchors.fill: parent
        color:appColors.c_background
        Column
        {
            width:parent.width/2
            height:parent.height/2
            anchors.centerIn: parent
            spacing:25
            CustomButton
            {
                setButtonText:"type practice"
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: parent.width
                setVisible: tableType==="word"
                setHeight:50
                anchors.horizontalCenter: parent.horizontalCenter
                onButtonClicked:
                {
                    joinMode("practiceModes/typePractice.qml", {practiceMode: tableType});
                    headerText.text = "Type Practice"
                }
            }
            CustomButton
            {
                setButtonText:"type practice only ⭐"
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: parent.width
                setVisible: tableType==="word"
                setHeight:50
                anchors.horizontalCenter: parent.horizontalCenter
                onButtonClicked:
                {
                    joinMode("practiceModes/typePractice.qml",
                             {
                                 practiceMode: tableType,
                                 practiceOnlyStarred: true
                             });
                    headerText.text = "Type Practice only starred words"
                }
            }

            CustomButton
            {
                setButtonText:"flashcard practice"
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: parent.width
                setVisible: tableType==="word"
                setHeight:50
                anchors.horizontalCenter: parent.horizontalCenter
                onButtonClicked:
                {
                    joinMode("practiceModes/flashcardPractice.qml", {practiceMode: tableType});
                    headerText.text = "Flashcard Practice"
                }
            }

            CustomButton
            {
                setButtonText:"flashcard practice only ⭐"
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: parent.width
                setVisible: tableType==="word"
                setHeight:50
                anchors.horizontalCenter: parent.horizontalCenter
                onButtonClicked:
                {
                    joinMode("practiceModes/flashcardPractice.qml",
                             {
                                 practiceMode: tableType,
                                 practiceOnlyStarred: true
                             });
                    headerText.text = "Flashcard Practice only starred words"
                }
            }

            CustomButton
            {
                setButtonText:"crossword practice"
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: parent.width
                setVisible: tableType==="word"
                setHeight:50
                anchors.horizontalCenter: parent.horizontalCenter
                onButtonClicked:
                {
                    joinMode("practiceModes/crosswordPractice.qml");
                    headerText.text = "Crossword Practice"
                }
            }
        }


    }


    Rectangle
    {
        id:resultBase
        color: appColors.c_background
        anchors.fill: parent
        visible: false;

        Column
        {
            width:parent.width/2
            height:parent.height/2
            anchors.centerIn: parent
            spacing:25

            Label
            {
                text: "mistakes: " + practiceResult["mistakeCount"]
                font.pixelSize: appFontSizes.f_large
                color: appColors.c_fontcolor
            }

            Label
            {
                text: "time spent: " + practiceResult["timeSpent"]
                font.pixelSize: appFontSizes.f_large
                color: appColors.c_fontcolor
            }

            CustomButton
            {
                setButtonText:"OK"
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: parent.width
                setHeight:50
                anchors.horizontalCenter: parent.horizontalCenter
                onButtonClicked:
                {
                    closeResult()
                }
            }
        }
    }







    function quitMode(saving=true,message="")
    {
        console.log("quitMode called. saving:",saving)
        practiceLoader.visible=false
        practiceLoader.source = ""

        if(saving===true)
        {
            resultBase.visible=true
            //saving on database, in order (mistakecount(str), timespent(str), practiceTypeid(int)
            backend.setPracticeResult(practiceResult["mistakeCount"],
                                      practiceResult["timeSpent"],
                                      practiceResult["practiceTypeId"]);
        }
        else
            selectPracticeBase.visible=true

        if(message.length>1)
            console.log("quitMode message=",message)
    }



    function closeResult()
    {
        resultBase.visible=false
        selectPracticeBase.visible=true
    }

    function joinMode(practiceSource, params = {})
    {
        practiceLoader.visible = true;
        selectPracticeBase.visible = false;

        if (Object.keys(params).length === 0)
            practiceLoader.source = practiceSource;
        else
            practiceLoader.setSource(practiceSource, params);
    }
    Component.onCompleted:
    {
        appVisibleBackOrMenuButton=false
    }
    Component.onDestruction:
    {
        appVisibleBackOrMenuButton=true
    }
}
