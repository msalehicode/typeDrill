import QtQuick
import QtQuick.Controls
import "CustomComponents"

Page
{
    header: Rectangle
    {
        width: parent.width
        height: 60
        color: appColors.c_headerBg
        Label
        {
            id:headerText
            text:"Settings"
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
    }

    Rectangle
    {
        anchors.fill: parent
        color:appColors.c_background

        Rectangle
        {
            width:parent.width/2
            height:50
            color:"transparent"
            radius:100
            anchors.horizontalCenter: parent.horizontalCenter

            CustomSwitchText
            {
                setWidth:parent.width
                setHeight:parent.height
                setRadius: parent.radius
                setBgColor: appColors.c_bg_tableList
                setSwitchColor: appColors.c_buttonBgColor
                setSwitchOpacity: 0.5
                setFontColor:appColors.c_fontcolor
                setFontSize: appFontSizes.f_normal
                setRighttText:"Dark"
                setLeftText: "Light"
                switchStatus: appColors.c_theme==="dark" ? true : false;
                anchors.centerIn: parent
                onSwitchClicked:
                {
                    if(switchStatus)
                    {
                        console.log("switched to dark theme")
                        backend.setThemeMode("dark");
                    }
                    else
                    {
                        console.log("switched to light theme")
                        backend.setThemeMode("light");
                    }
                    rootWindow.reloadTheme();

                    //manually reload icon
                    //often it's color is default theme since loading, doesn't change with theme while switching theme for dark to light
                    buttonBackOrDrawer.modifyIcon(appIcons.icon_back)
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


                Item
                {
                    width:parent.width/2
                    height:50
                    anchors.horizontalCenter: parent.horizontalCenter
                    Row
                    {
                        width:parent.width
                        height:parent.height
                        spacing:5
                        Label
                        {
                            text:"auto play audio\n on practice:"
                            color:appColors.c_fontcolor
                            font.pixelSize: appFontSizes.f_normal
                        }
                        CustomSwitch
                        {
                            setWidth:50
                            setHeight:30
                            setBgColorActivated: appColors.c_buttonBgColor
                            switchStatus:appSettings.autoPlayAudioOnPractice
                            // setStatusBorder:false;
                            onSwitchClicked:
                            {
                                 if(switchStatus)
                                 {
                                    appSettings.autoPlayAudioOnPractice=true
                                    backend.setSetting("autoPlayAudioOnPractice","true");
                                 }
                                 else
                                 {
                                    appSettings.autoPlayAudioOnPractice=false
                                    backend.setSetting("autoPlayAudioOnPractice","false");
                                 }
                            }
                        }
                    }



                    Row
                    {
                        width:parent.width
                        height:parent.height
                        spacing:5
                        Label
                        {
                            text:"save Text To Speech:"
                            color:appColors.c_fontcolor
                            font.pixelSize: appFontSizes.f_normal
                        }
                        CustomSwitch
                        {
                            setWidth:50
                            setHeight:30
                            setBgColorActivated: appColors.c_buttonBgColor
                            switchStatus:appSettings.saveTTSvoice
                            // setStatusBorder:false;
                            onSwitchClicked:
                            {
                                 if(switchStatus)
                                 {
                                    appSettings.saveTTSvoice=true
                                    backend.setSetting("saveTTSvoice","true");
                                 }
                                 else
                                 {
                                    appSettings.saveTTSvoice=false
                                    backend.setSetting("saveTTSvoice","false");
                                 }
                            }
                        }
                    }

                }




            }
        }

        Label
        {
            text:"version: " + backend.getVersion();
            horizontalAlignment: Text.AlignHCenter
            color: appColors.c_fontcolor
            font.pixelSize: appFontSizes.f_normal
            font.bold:true
            anchors
            {
                horizontalCenter:parent.horizontalCenter
                bottom:parent.bottom
            }
        }
    }

    Component.onCompleted:
    {
        apiUrlText.theText = backend.getApiUrl()
    }
}
