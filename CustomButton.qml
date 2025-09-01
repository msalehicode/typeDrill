import QtQuick 2.15
import QtQuick.Window 2.15
Item
{
    id:local_root;
    // anchors.fill: parent;
    width:setWidth
    height:setHeight
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
    property bool setBold: false
    property bool setVisible:true

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
            visible: setVisible
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
                    font.bold: setBold
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
