import QtQuick
import QtQuick.Controls

Item {
    anchors.fill: parent
    Rectangle
    {
        anchors.fill: parent
        color:"cyan"
        Button
        {
            anchors.centerIn: parent
            text:"set Color.."
            onClicked:
            {
                backend.setAndroidBarsColor(0xFF0000FF, 0xFFFF0000);
            }
        }
    }
}
