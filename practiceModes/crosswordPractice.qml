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
    property var crossword2: []


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

    //combine of vertical and horizontal
    ListModel
    {
        id: hintPoolModel
    }


    ListModel {
        id: tilePoolModel
    }



    Rectangle {
        anchors.fill: parent
        color: appColors.c_background




        Rectangle {
            id:crosswordBase
            width: crosswordGrid.rows*35 +50
            height: crosswordGrid.columns*35 +50
            color: appColors.c_background
            clip:true

            // Enable position change
            x: 0
            y: 0


            property real scaleFactor: 1.0

            transform: Scale {
                origin.x: crosswordBase.width / 2
                origin.y: crosswordBase.height / 2
                xScale: crosswordBase.scaleFactor
                yScale: crosswordBase.scaleFactor
            }


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
                                setVisible: model.index>-1 ? true : false
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
                                    showHintDialog(model.value,"v",model.index+1)
                                    console.log("clicked on vertical modelindex=",model.index)
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
                                    showHintDialog(model.value,"h",model.index+1)
                                }
                            }
                        }
                    }

                }


            }

            // Crossword grid container
            Grid {
                id:crosswordGrid
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
                                onExited: {
                                    if (movingLetterText === model.value && movingReleased) {
                                        movingItem.visible = false
                                        text.visible = true
                                        parent.color = "lime"

                                        let coords = model.address.split(",").map(Number)
                                        let x = coords[0]
                                        let y = coords[1]
                                        crossword2[x][y] = movingLetterText

                                        // --- Check horizontal line (row x)
                                        var horizontalMatch = true
                                        for (var col = 0; col < crossword[x].length; col++) {
                                            if (crossword[x][col] !== "") {
                                                if (crossword2[x][col] !== crossword[x][col]) {
                                                    horizontalMatch = false
                                                    break
                                                }
                                            }
                                        }
                                        if (horizontalMatch)
                                        {
                                            console.log("✅ Horizontal word completed at row:", x + 1)

                                            // Remove corresponding hint from hintPoolModel
                                            for (var i = 0; i < hintPoolModel.count; i++) {
                                                var item = hintPoolModel.get(i)
                                                if (item.direction === "h" && item.order === x) {
                                                    hintPoolModel.remove(i)
                                                    break
                                                }
                                            }
                                        }

                                        // --- Check vertical line (column y)
                                        var verticalMatch = true
                                        for (var row = 0; row < crossword.length; row++) {
                                            if (crossword[row][y] !== "") {
                                                if (crossword2[row][y] !== crossword[row][y]) {
                                                    verticalMatch = false
                                                    break
                                                }
                                            }
                                        }
                                        if (verticalMatch) {
                                            console.log("✅ Vertical word completed at column:", y + 1)

                                            // Remove corresponding hint from hintPoolModel
                                            for (var j = 0; j < hintPoolModel.count; j++) {
                                                var item2 = hintPoolModel.get(j)
                                                if (item2.direction === "v" && item2.order === y) {
                                                    hintPoolModel.remove(j)
                                                    break
                                                }
                                            }
                                        }

                                    }
                                }

                        }
                    }
                }
            }



            MouseArea
            {
                id: dragAreaContent
                anchors.fill: parent
                drag.target: parent
                propagateComposedEvents: true
            }



        }

    }




    Rectangle
    {
        id:controlCrosswordBase
        width: 30
        height:100
        color:"transparent"
        anchors
        {
            right:parent.right
            bottom:hintPool.top
        }
        Column
        {
            width: parent.width
            height:parent.height
            spacing:5

            CustomButtonWithIcon
            {
                setButtonText:"";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setIconSource: appIcons.icon_turn_white
                setIconWidth: 25
                setIconHeight: 25
                setButtonsBorderWidth: 0
                setRadius: 30
                setWidth: 30
                setHeight:30
                onButtonClicked:
                {
                    crosswordBase.scaleFactor = 1.0
                    crosswordBase.x=0
                    crosswordBase.y=0
                }
            }


            CustomButtonWithIcon
            {
                setButtonText:"";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setIconSource: appIcons.icon_zoomin_white
                setIconWidth: 25
                setIconHeight: 25
                setButtonsBorderWidth: 0
                setRadius: 30
                setWidth: 30
                setHeight:30
                onButtonClicked:
                {
                    crosswordBase.scaleFactor = Math.min(3.0, crosswordBase.scaleFactor + 0.1)
                }
            }

            CustomButtonWithIcon
            {
                setButtonText:"";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setIconSource: appIcons.icon_zoomout_white
                setIconWidth: 25
                setIconHeight: 25
                setButtonsBorderWidth: 0
                setRadius: 30
                setWidth: 30
                setHeight:30
                onButtonClicked:
                {
                    crosswordBase.scaleFactor = Math.max(0.5, crosswordBase.scaleFactor - 0.1)
                }
            }


        }
    }



    Flow {
        id: hintPool
        width: parent.width
        height: 100
        spacing: 10
        anchors.bottom: baseTilePool.top
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.margins: 15
        clip: true

        Repeater {
            model: hintPoolModel

            delegate: Rectangle
            {
                width:parent.width
                visible: model.value.length>0
                height:50
                color:appColors.c_comboboxBgColorCurrentItem
                Row
                {
                    width: parent.width
                    height:parent.height
                    spacing:10
                    Text {
                        text: model.order+1
                        width: 5
                        height: implicitHeight
                        color:appColors.c_fontcolor
                        font.pixelSize: appFontSizes.f_large
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    CustomButtonWithIcon
                    {
                        setButtonText:"";
                        setIconSource: appIcons.icon_arrow
                        setButtonBorderColor: "transparent"
                        setButtonBackColor: "transparent"
                        setButtonFontColor: "transparent"
                        setIconWidth: 25
                        setIconHeight: 25
                        setButtonsBorderWidth: 0
                        setRadius: 30
                        setIconRotation: model.direction==="h" ? 0 : 90
                        setWidth: 30
                        setHeight:30
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: model.value.length>0 ? model.value : "sorry, hint is empty"
                        width: implicitWidth>parent.width/1.50? parent.width/1.50: implicitWidth
                        height: implicitHeight
                        wrapMode: Text.WordWrap
                        color:appColors.c_fontcolor
                        font.pixelSize: appFontSizes.f_normal
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }


            }
        }
    }



    Rectangle
    {
        id:baseTilePool
        width: parent.width
        height: 150
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 10
        color:"grey"
        Flow {
            id: tilePool
            anchors.fill: parent
            spacing: 10


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
                        font.pointSize: appFontSizes.f_normal
                        font.bold: true
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

    }



    CustomPopupMessage
    {
        id:popupMessage
        setDefaultText: ""
        setFailColor: appColors.c_bgPopupContentFailed
        setSuccessColor:appColors.c_bgPopupContentSuccess
        setBgContent: appColors.c_bgPopupContentDefault
        setTextFontSize: appFontSizes.f_normal
        setTextColor:  appColors.c_fontcolor
        setBgColorPopup: appColors.c_background
        setBgOpacityPopup: 0.5
        setWidth: parent.width/1.50
        setHeight: 250

        Row
        {
            width: parent.width
            height:parent.height/2
            spacing:15
            anchors
            {
                top:parent.top
                topMargin:parent.height/5
            }

            Text
            {
                id:indexHint
                width: 80
                height:50
                anchors.horizontalCenter:parent.horizontalCenter
                color:appColors.c_fontcolor
                font.pixelSize: appFontSizes.f_title
            }
            CustomButtonWithIcon
            {
                id:directionHint
                setButtonText:"";
                setIconSource: appIcons.icon_arrow
                setButtonBorderColor: "transparent"
                setButtonBackColor: "transparent"
                setButtonFontColor: "transparent"
                setIconWidth: 30
                setIconHeight: 30
                setButtonsBorderWidth: 0
                setRadius: 30
                setWidth: 30
                setHeight:30
                anchors.horizontalCenter:parent.horizontalCenter
            }

        }



        CustomButton
        {
            id:buttonOkPopup
            setButtonText:"Ok got it";
            setButtonBorderColor:appColors.c_buttonBorderColor
            setButtonBackColor: appColors.c_buttonBgColor
            setButtonFontColor: appColors.c_buttonFontColor
            setBold: true
            setButtonFontsize: appFontSizes.f_buttonFontSize
            setButtonsBorderWidth: 0
            setRadius: 20
            setWidth: 70
            setHeight:50
            anchors
            {
                bottom:parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
            onButtonClicked:
            {
                popupMessage.close()
            }
        }
    }


    function showHintDialog(value,direction,index)
    {
        if(value.length<=0)
            popupMessage.open("sorry, hint is empty")
        else
            popupMessage.open(value)

        directionHint.setIconRotation= direction==="v"? 90 : 0
        indexHint.text= index

    }

    Connections
    {
        target:backend
        function onCrosswordReady(crosswordGrid,horizontalHint,verticalHint)
        {
            console.log("recived crosswordGrid data=",crosswordGrid)
            crossword=crosswordGrid;


            var i,j;

            listmodel.clear()

            //add received data and build tiles
            for (i = 0; i < crossword.length; i++)
            {
                for (j = 0; j < crossword[i].length; j++)
                {
                    const letter = crossword[i][j];

                    // Build crossword model
                    listmodel.append({ row: i, col: j, value: letter, address:(i)+","+(j)});

                    // Add to tile pool if it's a non-empty letter
                    if (letter !== "")
                    {
                        tilePoolModel.append({ letter: letter });
                    }
                }
            }


            //make an empty instance of crosswrod to crosswrod1
            for (var i = 0; i < crossword.length; i++) {
                var row = []
                for (var j = 0; j < crossword[i].length; j++) {
                    row.push("")
                }
                crossword2.push(row)
            }


            //add instructions
            // console.log("instruction vertical=",verticalHint)
            horizontalInstructionsList.clear()
            verticalInstructionsList.clear()
            for (i = 0; i < horizontalHint.length; i++)
                horizontalInstructionsList.append( { value: horizontalHint[i], direction: "h", order:i} );
            for (i = 0; i < verticalHint.length; i++)
                verticalInstructionsList.append( { value: verticalHint[i], direction: "v", order:i});


            //combine vertical and horizontal hints for hintPoolModel
            for (i = 0; i < horizontalInstructionsList.count; ++i)
                hintPoolModel.append(horizontalInstructionsList.get(i))
            for (j = 0; j < verticalInstructionsList.count; ++j)
                hintPoolModel.append(verticalInstructionsList.get(j))
        }
    }

    Component.onCompleted:
    {
        backend.makeCrossword();
        console.log("grid size="+crossword[0].length, "x", crossword.length)
    }
}
