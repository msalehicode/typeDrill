import QtQuick
import QtQuick.Controls

Item
{
    width:setWidth
    height:setHeight

    property int setWidth: 200
    property int setHeight: 50
    property color setBgColor:"black"
    property color setBordercolor: "red"
    property int setBorderWidth:0
    property int setFontSize:15
    property color setFontColor: "white"
    property int setRadius:10
    property string setTitleText:""
    property string theText:""
    Rectangle
    {
        color:setBgColor
        anchors.fill: parent
        radius:setRadius
        border.width: setBorderWidth
        border.color: setBordercolor
        Rectangle
        {
            color:setBgColor
            width:50
            height:10
            anchors
            {
                top:parent.top
                topMargin:-4
                left:parent.left
                leftMargin:15
            }
            Text
            {
                visible: setTitleText.length > 0 ? true : false
                text:setTitleText
                color: setFontColor
                font.pixelSize: setFontSize
                font.bold: true
                anchors.centerIn: parent
            }
        }



        TextInput
        {
            text:theText
            color:setFontColor
            font.pixelSize: setFontSize
            anchors
            {
                verticalCenter:parent.verticalCenter
                left:parent.left
                right:parent.right
                leftMargin:5
            }
            onTextChanged:
            {
                theText = text
            }
        }
    }
}
