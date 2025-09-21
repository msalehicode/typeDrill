import QtQuick
import QtQuick.Controls
import "../CustomComponents"

Item
{
    anchors.fill: parent
    property var parentPopup

    Column
    {
        spacing:20
        width: parent.width
        height:parent.height
        CustomTextInput
        {
            id:usernameInput
            setWidth: parent.width
            setHeight: 45
            setBgColor: appColors.c_bgColor_textinput
            setBordercolor: appColors.c_borderColor_textinput
            setBorderWidth:2
            setFocus: false
            setFontSize:appFontSizes.f_textInput
            setFontColor: appColors.c_fontColor_textinput
            setRadius:10
            theText:""
            setErrorPosfix: ""
            setErrorPrefix: ""
            setTitleText:"Username:"
            onTheTextAccepted:
            {
                passwordInput.focus=true
            }
        }
        CustomTextInput
        {
            id:passwordInput
            setWidth: parent.width
            setHeight: 45
            setBgColor: appColors.c_bgColor_textinput
            setBordercolor: appColors.c_borderColor_textinput
            setBorderWidth:2
            setFocus: false
            setFontSize:appFontSizes.f_textInput
            setFontColor: appColors.c_fontColor_textinput
            setRadius:10
            theText:""
            setErrorPosfix: ""
            setErrorPrefix: ""
            setTitleText:"Password:"
            onTheTextAccepted:
            {
                signinButton.buttonClicked()
            }
        }


        Row
        {
            spacing:20
            anchors.horizontalCenter: parent.horizontalCenter
            CustomButton
            {
                id:signinButton
                setButtonText:"Sign in";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 100
                setHeight: 50
                onButtonClicked:
                {
                    backend.signAccount("signin",usernameInput.theText, passwordInput.theText)
                    if(parentPopup)
                            parentPopup.open()
                }
            }


        }

    }

    Component.onCompleted:
    {
        //fill previous username
        var username = backend.getUsername();
        if(username.length>0)
            usernameInput.theText=username;
    }
}
