import QtQuick 2.15
import QtQuick.Window 2.15
Item
{
    id:local_root;
    width: setWidth;
    height: setHeight;
    Rectangle
    {
        anchors.fill: parent;
        color:"transparent"
    }

    property int setWidth: 25
    property int setHeight: 25
    property int setButtonsBorderWidth: 1;
    property int setRadius: 10;
    property int setWidthButtons: local_root.width;
    property int setHeightButtons: local_root.height;

    property int setTextMagin: 0
    property string setButtonText: "button";
    property color setButtonFontColor: "yellow";
    property color setButtonBackColor: "purple";
    property color setButtonBorderColor: "red";

    property string setIconSource: "resources/default.png";
    property int setIconWidth: 45
    property int setIconHeight: 45

    signal buttonClicked;


    Component
    {
        id: buttonComponent
        Rectangle
        {
            id:baseButtons;
            width:local_root.width;
            height:local_root.height;
            color:"transparent";

            Rectangle
            {
                id:button;
                width:setWidthButtons;
                height:setHeightButtons;
                color:setButtonBackColor;
                border.color:setButtonBorderColor;
                border.width: setButtonsBorderWidth;
                radius: setRadius;


                Image
                {
                    id:image
                    source: setIconSource
                    width: setIconWidth
                    height: setIconHeight
                    fillMode: Image.PreserveAspectFit
                    visible: setIconSource==="resources/default.png"||setIconSource==="" ? false:true
                    anchors
                    {
                        top:parent.top
                        horizontalCenter:parent.horizontalCenter
                    }
                }
                Text
                {

                    text:setButtonText;
                    color:setButtonFontColor;
                    font.bold: true
                    anchors
                    {
                        horizontalCenter:parent.horizontalCenter
                        top:image.bottom
                        topMargin:setTextMagin
                    }
                }


                MouseArea
                {
                    anchors.fill:parent;
                    onClicked:
                    {
                        buttonClicked()
                    }
                }
            }

        }


    }

    Loader
    {
        sourceComponent: buttonComponent;
    }
}
