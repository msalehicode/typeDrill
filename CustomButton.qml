import QtQuick 2.15
import QtQuick.Window 2.15
Item
{
    id:local_root;
    // anchors.fill: parent;
    width:bwidth
    height:bheight
    Rectangle
    {
        anchors.fill: parent;
        color:"black"
    }
    property int bwidth: 25
    property int bheight: 25
    property int setButtonsBorderWidth: 1;
    property int setRadius: 10;
    property int setWidthButtons: local_root.width;
    property int setHeightButtons: local_root.height;

    property string setButtonText: "button";
    property color setButtonFontColor: "yellow";
    property color setButtonBackColor: "purple";
    property color setButtonBorderColor: "red";
    property int setButtonFontsize: 12;
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
                Text
                {
                    text:setButtonText;
                    anchors.centerIn:parent;
                    color:setButtonFontColor;
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
