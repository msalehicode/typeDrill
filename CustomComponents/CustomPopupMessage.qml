import QtQuick
import QtQuick.Controls

Item {
    anchors.fill: parent
    visible: setOpen

    //to beable add content/other Components inside this component. like buttons,...
    default property alias content: contentArea.children



    property bool setOpen: false
    property string setDefaultText: "please wait..."
    property color setFailColor: "red"
    property int setTextFontSize: 15
    property color setTextColor: "white"
    property color setSuccessColor:"green"
    property color setBgColorPopup: "black"
    property color setBgContent: "grey"

    property int setRadius: 10


    property int setWidth: 0
    property int setHeight: 0


    function open(strText="")
    {
        if(strText.length>0)
            setDefaultText=strText

        setOpen=true
        popup.open()
    }

    function setResult(message,status="0")
    {
        setDefaultText=message
        if(status==="0")
            popupContent.color=setFailColor
        else
            popupContent.color=setSuccessColor

        popUpStatusChanged()
    }

    function close()
    {
        popup.close()
    }

    signal popUpStatusChanged;
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
            popUpClosed()
            popupContent.color= setBgContent
            // popupContentText.text= setDefaultText
            setOpen=false
        }

        Rectangle
        {
            id:popupContent
            width: setWidth == 0 ? parent.width/2 : setWidth
            height: setHeight == 0 ? parent.height/2 : setHeight
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

            //to beable add content/other Components inside this component. like buttons,...
            Item
            {
                id: contentArea
                anchors.fill: parent
            }
        }



    }

}
