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

            Rectangle
            {
                width:parent.width/1.10
                height:310
                anchors.horizontalCenter: parent.horizontalCenter
                color:appColors.c_background
                clip:true
                Column
                {
                    id:rowSingout
                    width:parent.width
                    height:parent.height
                    visible:isLoggedin
                    spacing:5
                    Rectangle
                    {
                        id:accountInfo
                        width:parent.width
                        height:50
                        color:"transparent"
                        Label
                        {
                            id:signedInUsername
                            text:"Username"
                            color:appColors.c_fontcolor
                            font.pixelSize: appFontSizes.f_title
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        CustomButtonWithIcon
                        {
                            id:buttonSignout
                            setButtonText:"";
                            setIconSource: appIcons.icon_signout
                            setButtonBorderColor: "transparent"
                            setButtonBackColor: appColors.c_bgPopupContentFailed
                            setButtonFontColor: "transparent"
                            setIconWidth: 30
                            setIconHeight: 30
                            setButtonsBorderWidth: 0
                            setRadius: 50
                            setWidth: 50
                            setHeight:50
                            onButtonClicked:
                            {
                                backend.signAccount("signout")
                                popup.open()
                            }
                            anchors
                            {
                                right:parent.right
                                verticalCenter: parent.verticalCenter
                            }
                        }

                    }

                }

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
        setWidth: parent.width/1.50
        setHeight: 250
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
            console.log("result sign=",result)
            if(result.length===32)//md5 hash length
            {
                popup.setResult("signed in successfully","1")
                backend.setSessionKey(result);
                signedInUsername.text = "welcome " + backend.getUsername();
                isLoggedin=true
            }
            else if(result==="sessionKey not found") //this is from backend not API response!
            {
                //do nothing
            }

            else if(result==="Successfully logged out")
            {
                popup.setResult("Successfully signed out","1");
                backend.setSessionKey("");
                isLoggedin=false;
            }

            else if(result==="Invalid session, You must sign-in" || //when session is expired or user made new session by other login
                    result==="Session has expired, Please sign-in") //when session is expired or user made new session by other login
            {
                popup.setResult("Session has expired or another device signed in","0");
                backend.setSessionKey("");
                isLoggedin=false;
            }
            else if(result === "is valid")
            {
                popup.close();
                isLoggedin=true;
            }
            else if(result.includes("Network error:"))
            {
                //do nothing
                popup.setResult("You're offline, check your network or try again later","0");
            }

            else
            {
                popup.setResult(result,"0")
            }
        }
    }

    Component.onCompleted:
    {
        //just ask server session is ok or not, for those times user sesionKey is changed by other device or sing-in
        if(backend.getSessionKey().length>0)
        {
            isLoggedin=true //to avoid showing sign in/up form
            backend.isSessionValid();
            popup.open("checking session..");
            signedInUsername.text = "welcome " + backend.getUsername();
        }
        else
            isLoggedin=false;
    }
}
