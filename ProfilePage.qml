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
                height:300
                anchors.horizontalCenter: parent.horizontalCenter
                color:appColors.c_background
                Text
                {
                    text:"login stuff..."
                    anchors.centerIn: parent
                    font.pixelSize: appFontSizes.f_title
                    color:appColors.c_fontcolor
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
                ActivityStats
                {
                    setWidth:parent.width
                    setHeight: parent.height
                }
            }



        }


    }
}
