import QtQuick
import QtQuick.Controls
import "../CustomComponents"

Page {
    property var crossword: [
        ["", "C", "A", "T", "","","","",""],
        ["", "", "R", "", "","","","",""],
        ["", "", "A", "", "","","","",""],
        ["", "", "N", "O", "O","B","","",""],
        ["", "", "", "", "","R","","",""],
        ["", "", "", "", "","B","","",""]
    ]


    property bool movingReleased:false
    property string movingLetterText;
    property Rectangle movingItem;

    ListModel
    {
        id:listmodel
    }


    ListModel
    {
        id:horizontalInstructionsList
    }

    ListModel
    {
        id:verticalInstructionsList
    }


    ListModel {
        id: tilePoolModel
    }



    Rectangle {
        width: parent.width
        height: parent.height
        // anchors.centerIn:parent
        color: appColors.c_background
        clip:true

        Rectangle
        {
            id:instructionForVerticals
            width: parent.width
            height: 30
            color:"transparent"
            anchors.left: parent.left
            anchors.leftMargin: 30
            Row
            {
                width: parent.width
                height: parent.height
                spacing:5
                Repeater
                {
                    model:verticalInstructionsList

                    delegate: Rectangle
                    {
                        width: 30
                        height: 30
                        color: "transparent"
                        CustomButtonWithIcon
                        {
                            setButtonText:"";
                            setIconSource: appIcons.icon_arrow
                            setButtonBorderColor: "transparent"
                            setButtonBackColor: "transparent"
                            setButtonFontColor: "transparent"
                            setIconWidth: 15
                            setIconHeight: 15
                            setButtonsBorderWidth: 0
                            setVisible: model.value === "" ? false : true
                            setRadius: 15
                            setIconRotation: 90
                            setWidth: 15
                            setHeight:15
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }
                        Text
                        {
                            text:model.index+1
                            anchors.centerIn: parent
                            color:appColors.c_fontcolor
                            font.pixelSize: appFontSizes.f_normal
                        }
                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                console.log(model.value)
                            }
                        }
                    }
                }

            }


        }

        Rectangle
        {
            id:instructionForHorizontal
            width: 30
            height: parent.height
            color:"transparent"
            anchors.top: instructionForVerticals.bottom
            Column
            {
                width: parent.width
                height: parent.height
                spacing:5
                Repeater
                {
                    model:horizontalInstructionsList

                    delegate: Rectangle
                    {
                        width: 30
                        height: 30
                        color: "transparent"
                        CustomButtonWithIcon
                        {
                            setButtonText:"";
                            setIconSource: appIcons.icon_arrow
                            setButtonBorderColor: "transparent"
                            setButtonBackColor: "transparent"
                            setButtonFontColor: "transparent"
                            setIconWidth: 15
                            setIconHeight: 15
                            setButtonsBorderWidth: 0
                            setVisible: model.index>-1 ? true : false
                            setRadius: 15
                            setWidth: 15
                            setHeight:15
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                        }
                        Text
                        {
                            text:model.index+1
                            anchors.centerIn: parent
                            color:appColors.c_fontcolor
                            font.pixelSize: appFontSizes.f_normal
                        }
                        MouseArea
                        {
                            anchors.fill: parent
                            onClicked:
                            {
                                console.log(model.value)
                            }
                        }
                    }
                }

            }


        }

        // Crossword grid container
        Grid {
            columns : crossword[0].length
            rows: crossword.length
            spacing: 5
            anchors
            {
                left:instructionForHorizontal.right
                top:instructionForVerticals.bottom
            }

            // Iterate through the grid cells
            Repeater {
                model:listmodel

                delegate: Rectangle
                {
                    id:rectWord
                    width: 30
                    height: 30
                    color: "transparent"
                    border.width: 1
                    border.color: model.value === "" ? "transparent" : "grey"

                    Text {
                        id:text
                        anchors.centerIn: parent
                        text: model.value
                        visible: false
                        font.pointSize: 16
                        color: appColors.c_fontcolor
                    }

                    DropArea {
                            anchors.fill: parent
                            onExited:
                            {
                                if(movingReleased)
                                {

                                    // console.log("drropped item text=",movingLetterText)
                                    // console.log("parrent pos x=",parent.x, "y=",parent.y)

                                    if (movingLetterText === model.value)
                                    {
                                        // movingItem.color="green"
                                        movingItem.visible=false
                                        text.visible=true
                                        parent.color= "green"
                                    }
                                    // else
                                    // {
                                    //     movingItem.color="red"
                                    // }
                                }
                            }
                        }
                }
            }
        }
    }


    Flow {
        id: tilePool
        width: parent.width
        height: 150
        spacing: 10
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 10

        Repeater {
            model: tilePoolModel

            delegate: Rectangle {
                width: 30
                height: 30
                radius: 4
                color: "#f5f5f5"
                border.color: "black"

                property string letter: model.letter

                Text {
                    anchors.centerIn: parent
                    text: letter
                    font.pointSize: 14
                    color: "black"
                }

                Drag.active: dragArea.pressed
                Drag.hotSpot.x: width / 2
                Drag.hotSpot.y: height / 2


                // Drag.dragType: Drag.Automatic
                Drag.source: parent
                MouseArea {
                    id: dragArea
                    anchors.fill: parent
                    drag.target: parent
                    onPressed: {
                        movingLetterText=letter
                        movingReleased=false
                        movingItem=parent
                    }
                    onReleased:
                    {
                        movingReleased=true
                    }
                }
            }
        }
    }



    Connections
    {
        target:backend
        function onCrosswordReady(crosswordGrid,horizontalHint,verticalHint)
        {
            console.log("recived crosswordGrid data=",crosswordGrid)
            crossword=crosswordGrid;
            const charCount = {};


            listmodel.clear()

            //add received data and build tiles
            for (var i = 0; i < crossword.length; i++) {
                for (var j = 0; j < crossword[i].length; j++) {
                    const letter = crossword[i][j];

                    // Build crossword model
                    listmodel.append({ row: i, col: j, value: letter });

                    // Add to tile pool if it's a non-empty letter
                    if (letter !== "") {
                        tilePoolModel.append({ letter: letter });
                    }
                }
            }

            //add instructions
            // console.log("instruction vertical=",verticalHint)
            horizontalInstructionsList.clear()
            verticalInstructionsList.clear()
            for (var i = 0; i < horizontalHint.length; i++)
                horizontalInstructionsList.append( { value: horizontalHint[i]} );
            for (var i = 0; i < verticalHint.length; i++)
                verticalInstructionsList.append( { value: verticalHint[i]} );
        }
    }

    Component.onCompleted:
    {
        console.log("grid size="+crossword[0].length, "x", crossword.length)
        backend.makeCrossword();
    }
}
