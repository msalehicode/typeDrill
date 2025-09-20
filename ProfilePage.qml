import QtQuick
import QtQuick.Controls
import "CustomComponents"
import QtCharts

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
            text:"Profile"
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

    property bool isLoggedin: false;

    Rectangle
    {
        anchors.fill: parent
        color:appColors.c_background

        Column
        {
            width:parent.width
            height:parent.height
            spacing:5

            CustomButton
            {
                id:signoutButton
                setVisible: isLoggedin
                setButtonText:"Sign out";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonCancelBgColor
                setButtonFontColor: appColors.c_buttonCancelFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: isLoggedin ? 100 : 0
                setHeight: isLoggedin ? 50 : 0
                onButtonClicked:
                {
                    backend.signAccount("signout")
                    popup.open()
                }
            }
            Rectangle
            {
                width:parent.width/1.10
                height:310
                anchors.horizontalCenter: parent.horizontalCenter
                color:appColors.c_background
                clip:true
                Column
                {
                    id:columnAccountSignInUp
                    visible: !isLoggedin
                    width:parent.width
                    height:parent.height
                    spacing:15
                    Item
                    {
                        //spacer
                        width:1
                        height:7
                    }
                    CustomSwitchText
                    {
                        setWidth:parent.width
                        setHeight:40
                        setRadius: 40
                        setBgColor: appColors.c_bg_tableList
                        setSwitchColor: appColors.c_buttonBgColor
                        setSwitchOpacity: 0.5
                        setFontColor:appColors.c_fontcolor
                        setFontSize: appFontSizes.f_normal
                        setRighttText:"Sign Up"
                        setLeftText: "Sign In"
                        switchStatus: false
                        onSwitchClicked:
                        {
                            if(switchStatus)
                            {
                                console.log("switched to sign up")
                                loaderSignInSignUp.source="./items/Signup.qml"
                            }
                            else
                            {
                                console.log("switched to sign in")
                                loaderSignInSignUp.source="./items/Signin.qml"
                            }
                        }
                    }

                    Loader
                    {
                        id:loaderSignInSignUp
                        width:parent.width/1.25
                        height:240
                        anchors.horizontalCenter: parent.horizontalCenter
                        source:"./items/Signin.qml"
                        onLoaded: {
                            // Pass the popup to the loaded component
                            if (loaderSignInSignUp.item)
                            {
                                loaderSignInSignUp.item.parentPopup = popup
                            }
                        }
                    }
                }

            }



            Text
            {
                text:"Stats:"
                width: parent.width
                height:35
                font.pixelSize: appFontSizes.f_title
                color:appColors.c_fontcolor
                anchors.left: parent.left
                anchors.leftMargin: 25
            }

            Rectangle
            {
                width:parent.width/1.10
                anchors.horizontalCenter: parent.horizontalCenter
                height:350
                color:"transparent"
                clip:true
                Loader
                {
                    anchors.fill: parent
                    source: "./items/ActivityStats.qml"
                }
            }
        }


    }


    CustomPopupMessage
    {
        id: popup
        setDefaultText: "please wait..."
        setFailColor: appColors.c_bgPopupContentFailed
        setSuccessColor:appColors.c_bgPopupContentSuccess
        setBgContent: appColors.c_bgPopupContentDefault
        setTextFontSize: appFontSizes.f_normal
        setTextColor:  appColors.c_fontcolor
        setBgColorPopup: appColors.c_background
        onPopUpClosed:
        {
            //reset text after close and hide button
            setDefaultText= "please wait..."
            buttonOkPopup.setVisible=false
        }
        onPopUpStatusChanged:
        {
            //show button
            buttonOkPopup.setVisible=true
        }

        CustomButton
        {
            id:buttonOkPopup
            setButtonText:"Ok got it";
            setButtonBorderColor:appColors.c_buttonBorderColor
            setButtonBackColor: appColors.c_buttonBgColor
            setButtonFontColor: appColors.c_buttonFontColor
            setBold: true
            setVisible: false
            setButtonFontsize: appFontSizes.f_buttonFontSize
            setButtonsBorderWidth: 0
            setRadius: 20
            setWidth: 70
            setHeight:50
            anchors
            {
                bottom:parent.bottom
                horizontalCenter:parent.horizontalCenter
            }
            onButtonClicked:
            {
                popup.close()
            }
        }

    }


    Connections
    {
        target:backend
        function onSignResult(result)
        {
            if(result.length===32)//md5 hash length
            {
                popup.setResult(result,"1")
                console.log("signed in / signed up fine and result=", result)
                backend.setSessionKey(result);
                isLoggedin=true
            }
            else if(result==="Successfully logged out")
            {
                popup.setResult(result,"1")
                backend.setSessionKey("");
                isLoggedin=false
            }

            else
            {
                console.log("failed to signin / signup / signout failed, " + result)
                popup.setResult(result,"0")
            }
        }
    }

    Component.onCompleted:
    {
        isLoggedin = backend.getSessionKey().length>0 ? true : false
    }
}
