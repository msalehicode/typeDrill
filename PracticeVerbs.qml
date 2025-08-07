import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Page
{
    anchors.fill: parent
    property int currentIndex: 0;
    property int passedState:0;
    Rectangle
    {
        color:"#222424"
        anchors.fill: parent
        Item
        {
            id:itemContent
            anchors.fill: parent
            Label
            {
                text:currentIndex
                font.pixelSize: 25
                color:"white"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: 25
                anchors.leftMargin: 25
            }
            PracticeTimeComponent
            {

            }

            RowLayout
            {
                id:rowPractice
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing:50
                Label
                {
                    id:v_verb
                    text:"v_verb"
                    font.pixelSize: 30
                    color:"white"
                    horizontalAlignment: Text.AlignHCenter  // Center text horizontally
                    Layout.fillWidth: true                   // Fill the available width
                    wrapMode: Text.WordWrap                  // Enable text wrapping if text is long

                }
                Label
                {
                    id:v_past
                    text:"v_past"
                    font.pixelSize: 30
                    color:"white"
                    horizontalAlignment: Text.AlignHCenter  // Center text horizontally
                    Layout.fillWidth: true                   // Fill the available width
                    wrapMode: Text.WordWrap                  // Enable text wrapping if text is long
                }
                Label
                {
                    id:v_past_perfect
                    text:"v_past_perfect"
                    font.pixelSize: 30
                    color:"white"
                    horizontalAlignment: Text.AlignHCenter  // Center text horizontally
                    Layout.fillWidth: true                   // Fill the available width
                    wrapMode: Text.WordWrap                  // Enable text wrapping if text is long
                }

            }

            Rectangle
            {
                width: 200;
                height: 50
                anchors.top: rowPractice.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 25
                // Layout.alignment: Qt.AlignHCenter   // Align horizontally center in layout
                color:"transparent"
                border.color: "grey";
                TextInput
                {
                    id:text_input
                    text:"type"
                    color:"white"
                    font.pixelSize: 30
                    anchors.fill: parent
                    focus: true;
                    onAccepted:
                    {
                        switch(passedState)
                        {
                            case 0:
                            {
                                if(text===v_verb.text)
                                {
                                    passedState++;
                                    text_input.clear()
                                    v_verb.font.bold=false
                                    v_past.font.bold=true;
                                    v_past_perfect.font.bold=false;
                                }
                            }break;
                            case 1:
                            {
                                if(text===v_past.text)
                                {
                                    passedState++;
                                    text_input.clear()
                                    v_verb.font.bold=false
                                    v_past.font.bold=false;
                                    v_past_perfect.font.bold=true;
                                }
                            }break;
                            case 2:
                            {
                                if(text===v_past_perfect.text)
                                {
                                    backend.getNextWord(v_verb.text)//to get next one
                                    text_input.clear()
                                }
                            }break;
                            default:
                                console.log("passedState invalid.")
                        }

                    }
                }
            }


        }

    }

    Connections
    {
        target: backend
        function onWordReady(word)
        {
            v_verb.text = word[0]
            v_past.text = word[1]
            v_past_perfect.text = word[2]
            text_input.clear()
            passedState=0;
            currentIndex++;

            v_verb.font.bold=true
            v_past.font.bold=false;
            v_past_perfect.font.bold=false;
        }
    }
    Component.onCompleted:
    {
        //to fetch first word
        backend.getNextWord("")
        currentIndex=0;
        passedState=0
    }
    Component.onDestruction:
    {
        backend.resetPractice();
        currentIndex=0;
        console.log("quiting the practice");
    }
}
