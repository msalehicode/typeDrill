import QtQuick
import QtQuick.Controls
import "../CustomComponents"

Page {
    width: parent ? parent.width : 400
    height: parent ? parent.height : 400

    anchors.top: parent.top
    anchors.topMargin: 60

    property var crossword: [
        ["", "C", "A", "T", "","","","",""],
        ["", "", "R", "", "","","","",""],
        ["", "", "A", "", "","","","",""],
        ["", "", "N", "O", "O","B","","",""],
        ["", "", "", "", "","R","","",""],
        ["", "", "", "", "","B","","",""]
    ]

    Rectangle {
        width: parent.width
        height: parent.height
        // anchors.centerIn:parent
        color: "grey"
        clip:true

        // Crossword grid container
        Grid {
            columns : crossword[0].length
            rows: crossword.length
            spacing: 5

            // Iterate through the grid cells
            Repeater {
                model: ListModel {
                    // Flatten the 2D crossword array into a 1D model
                    Component.onCompleted: {
                        for (var i = 0; i < crossword.length; i++) {
                            for (var j = 0; j < crossword[i].length; j++) {
                                append({ row: i, col: j, value: crossword[i][j] });
                            }
                        }
                    }
                }

                delegate: Rectangle
                {
                    id:rectWord
                    width: 50
                    height: 50
                    color: model.value === "" ? "transparent" : "blue"
                    border.width: 2
                    border.color:"transparent"

                    Text {
                        anchors.centerIn: parent
                        text: model.value
                        visible: model.value === "" ? false : true
                        font.pointSize: 16
                        color: "black"
                    }

                    TextField {
                        anchors.centerIn: parent
                        background:Rectangle
                        {
                            id:textFieldBg
                            color:"black"
                        }

                        width: parent.width
                        height: parent.height
                        font.pointSize: 16
                        inputMethodHints: Qt.ImhPreferUppercase
                        visible: model.value === "" ? false : true
                        color:"black"
                        maximumLength: 1
                        onTextChanged:
                        {
                            console.log(model.value, " " , text)
                            text = text.toUpperCase();

                            // Check if the user input matches the crossword value for this specific cell
                            if (text === model.value) {
                                textFieldBg.color="green"
                                console.log("correct")
                            } else {
                                if(text.length===0)
                                    textFieldBg.color="black"
                                else
                                    textFieldBg.color="red"
                                console.log("incorrect")
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log(crossword[0].length, " ", crossword.length)
    }
}
