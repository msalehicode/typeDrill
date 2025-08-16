import QtQuick 2.15
import QtQuick.Controls 2.15

Item
{
    width: 200
    height: 100
    anchors.top:parent.top
    anchors.right: parent.right
    anchors.topMargin: 25
    anchors.rightMargin: 25

    property int secondsPassed: 0
    signal eachTrigger;

    Timer {
        id: timer
        interval: 1000  // 1 second
        repeat: true
        running: true
        onTriggered: {
            secondsPassed += 1

            // Calculate hours, minutes, seconds
            var hours = Math.floor(secondsPassed / 3600);
            var minutes = Math.floor((secondsPassed % 3600) / 60);
            var seconds = secondsPassed % 60;

            // Format as hh:mm:ss with leading zeros
            var timeStr = (hours < 10 ? "0" + hours : hours) + ":" +
                          (minutes < 10 ? "0" + minutes : minutes) + ":" +
                          (seconds < 10 ? "0" + seconds : seconds);

            displayPassedTime.text = "Time passed: " + timeStr;
            eachTrigger();
        }
    }

    Label
    {
        id:displayPassedTime
        anchors.centerIn: parent
        font.pixelSize: 20
        color:"cyan"
    }
}
