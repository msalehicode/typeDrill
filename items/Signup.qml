import QtQuick
import QtQuick.Controls
import "../CustomComponents"

Item
{
    anchors.fill: parent
    property var parentPopup

    Column
    {
        spacing:15
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
                emailInput.focus=true
            }
        }
        CustomTextInput
        {
            id:emailInput
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
            setTitleText:"Email:"
            onTheTextAccepted:
            {
                passwordInput.buttonClicked()
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
                signupButton.buttonClicked()
            }
        }

        CustomButton
        {
            id:signupButton
            setButtonText:"Sign up";
            setButtonBorderColor:appColors.c_buttonBorderColor
            setButtonBackColor: appColors.c_buttonBgColor
            setButtonFontColor: appColors.c_buttonFontColor
            setBold: true
            setButtonFontsize: appFontSizes.f_buttonFontSize
            setButtonsBorderWidth: 0
            setRadius: 20
            setWidth: 100
            setHeight: 45
            anchors.horizontalCenter: parent.horizontalCenter
            onButtonClicked:
            {
                console.log("signup..")
                backend.signAccount("signup",usernameInput.theText, passwordInput.theText, emailInput.theText)
                if (parentPopup)
                        parentPopup.open()
            }
        }

    }
}
