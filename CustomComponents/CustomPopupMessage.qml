import QtQuick
import QtQuick.Controls

Item {
    anchors.fill: parent
    visible: setOpen
    property bool setOpen: false
    property string setDefaultText: "please wait..."
    property string setBtnText: "Ok"
    property color setFailColor: "red"
    property int setTextFontSize: 15
    property color setTextColor: "white"
    property color setSuccessColor:"green"
    property color setBgColorPopup: "black"
    property color setBgContent: "grey"

    property int setRadius: 10


    property color setBgButton: "blue"
    property color setBordercolorButton: "blue"


    function open()
    {
        setOpen=true
        popup.open()
    }

    function setResult(message,status="0")
    {
        popupContentText.text=message
        buttonClosePopup.setVisible=true
        if(status==="0")
            popupContent.color=setFailColor
        else
            popupContent.color=setSuccessColor
    }

    signal popUpClosed;


    Popup {
        id: popup
        width: parent.width
        height: parent.height
        modal: true
        focus: true

        background: Rectangle
        {
            color: setBgColorPopup
        }
        onClosed:
        {
            //reset color,text
            popupContent.color= setBgContent
            popupContentText.text= setDefaultText
            buttonClosePopup.setVisible=false
            setOpen=false
            popUpClosed()
        }

        Rectangle
        {
            id:popupContent
            width: parent.width/2
            height: parent.height/2
            anchors.centerIn: parent
            color: setBgContent
            radius:setRadius
            clip:true
            Text
            {
                id:popupContentText
                text:setDefaultText
                font.pixelSize: setTextFontSize
                color:setTextColor
                anchors.centerIn: parent
                width:parent.width/2
                height:parent.height/4
                wrapMode: Text.WordWrap
            }

            CustomButton
            {
                id:buttonClosePopup
                setButtonText:setBtnText;
                setButtonBorderColor:setBordercolorButton
                setButtonBackColor: setBgButton
                setButtonFontColor: setTextFontSize
                setBold: true
                setButtonFontsize: setTextFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: parent.width/2
                setHeight:50
                anchors
                {
                    bottom: parent.bottom
                    bottomMargin:15
                    horizontalCenter: parent.horizontalCenter
                }
                setVisible: false
                onButtonClicked:
                {
                    popup.close()
                }
            }
        }



    }

}
