import QtQuick
import QtQuick.Controls

Page
{
    anchors.fill: parent
    Rectangle
    {
        anchors.fill: parent
        color:appColors.c_background

        Rectangle
        {
            width:parent.width/2
            height:50
            color:"transparent"
            anchors
            {
                top:parent.top
                right:parent.right
                rightMargin:15
            }

            Text
            {
                id:switchThemeText
                text:"Dark Theme: "
                color:appColors.c_fontcolor
                font.pixelSize: appFontSizes.f_normal
                anchors.centerIn: parent
            }

            CustomSwitch
            {
                anchors.left: switchThemeText.right
                anchors.top: switchThemeText.top
                setWidth:50
                setHeight:40
                setBorderWidth: 4;
                setBgColorActivated: appColors.c_buttonBgColor
                switchStatus:appColors.c_theme==="dark" ? true : false;
                setStatusBorder:false;
                setSizeSwitchCircle: 2.80;
                onSwitchSignalClicked:
                {
                    if(switchStatus==true)
                        backend.setThemeMode("dark");
                    else
                        backend.setThemeMode("light");


                    rootWindow.reloadTheme();
                }
            }
        }

        Rectangle
        {
            color:"transparent"
            width:parent.width/1.15
            height:parent.height/2
            anchors.centerIn: parent

            Column
            {
                width:parent.width
                height: parent.height
                spacing: 15
                Rectangle
                {
                    color:"transparent"
                    width:parent.width
                    height:80
                    anchors.horizontalCenter: parent.horizontalCenter
                    CustomTextInput
                    {
                        id:apiUrlText
                        setWidth: parent.width-100
                        setHeight: 50
                        setBgColor: appColors.c_bgColor_textinput
                        setBordercolor: appColors.c_borderColor_textinput
                        setBorderWidth:2
                        setFontSize:appFontSizes.f_textInput
                        setFontColor: appColors.c_fontColor_textinput
                        setRadius:10
                        theText:"api url..."
                        setTitleText:"Api Url:"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    CustomButtonWithIcon
                    {
                        id:buttonUpdateApiUrl
                        setButtonText:"";
                        setIconSource: appIcons.icon_save_white
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setIconWidth: 30
                        setIconHeight: 30
                        setButtonsBorderWidth: 0
                        setRadius: 50
                        setWidth: 50
                        setHeight:50
                        anchors
                        {
                            top:apiUrlText.top
                            left:apiUrlText.right
                            leftMargin:1
                        }
                        onButtonClicked:
                        {
                            backend.setApiUrl(apiUrlText.theText)
                        }
                    }
                }


                Rectangle
                {
                    color:"transparent"
                    width:parent.width
                    height:80
                    anchors.horizontalCenter: parent.horizontalCenter
                    CustomTextInput
                    {
                        id:apiKeyText
                        setWidth: parent.width-100
                        setHeight: 50
                        setBgColor: appColors.c_bgColor_textinput
                        setBordercolor: appColors.c_borderColor_textinput
                        setBorderWidth:2
                        setFontSize:appFontSizes.f_textInput
                        setFontColor: appColors.c_fontColor_textinput
                        anchors.horizontalCenter: parent.horizontalCenter
                        setRadius:10
                        theText:"api key..."
                        setTitleText:"Api Key:"
                    }

                    CustomButtonWithIcon
                    {
                        id:buttonUpdateApiKey
                        setButtonText:"";
                        setIconSource: appIcons.icon_save_white
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setIconWidth: 30
                        setIconHeight: 30
                        setButtonsBorderWidth: 0
                        setRadius: 50
                        setWidth: 50
                        setHeight:50
                        anchors
                        {
                            top:apiKeyText.top
                            left:apiKeyText.right
                            leftMargin:1
                        }
                        onButtonClicked:
                        {
                            backend.setApiKey(apiKeyText.theText)
                        }
                    }
                }



            }
        }
    }

    Component.onCompleted:
    {
        apiUrlText.theText = backend.getApiUrl()
        apiKeyText.theText = backend.getApiKey()
    }
}
