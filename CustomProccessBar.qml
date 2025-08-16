import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: root
    width: 300
    height: 60
    anchors.horizontalCenter: parent.horizontalCenter

    Rectangle
    {
        anchors.fill: parent
        color:"transparent"
    }

    // Props
    property int currentValue: 20
    property int totalValue: 82

    Column {
        spacing: 6
        anchors.centerIn: parent

        // Text: "20 of 82"
        Text {
            text: currentValue + " of " + totalValue
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            color:"red"
            width: parent.width
        }

        // ProgressBar
        ProgressBar {
            from: 0
            to: totalValue
            value: currentValue
            width: parent.width
        }
    }
}
