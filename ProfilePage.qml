import QtQuick
import QtQuick.Controls

Page
{
    width:parent.width
    height: parent.height
    Rectangle
    {
        anchors.fill: parent
        color:appColors.c_background
        Text
        {
            text:"soon"
            color:appColors.c_fontcolor
            font.pixelSize: appFontSizes.f_title
            anchors.centerIn: parent
        }
    }
}
