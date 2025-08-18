import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Page
{
    id:homePage
    anchors.fill: parent
    property var days: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    property var statuses: [1, 0, 1, 0, 0, 1, 0]
    property var gridModel: []



    function refresh() {
           console.log("HomePage is refreshed!");
            //fetch and set available databases
            var files = backend.listOfDatabases();
            comboboxDatabases.modelData = sqliteListToModel(files);


            //fetch and set day streaks



            //fetch tables/decks
            backend.getTables("");  // Or "" for all
       }

    Rectangle
    {
        anchors.fill: parent;
        color:"#222424"

        Rectangle
        {
            id:topBar
            width: parent.width
            height:55
            color :"red"
            CustomComboboxWithIcon
            {
                id: comboboxDatabases
                anchors
                {
                    right:parent.right
                    rightMargin:15
                    verticalCenter:parent.verticalCenter
                }
                onActivated: function(index)
                {
                    var result = backend.switchDatabase(modelData[index].text);
                    if(result==="successed")
                    {
                        currentIndex = index
                        // console.log("Selected:", modelData[currentIndex].text)
                        refresh()
                    }
                    else
                    {
                        console.log("could not switch database.");
                    }
                }
            }


        }

        Rectangle
        {
            id:baseContentHomePage
            color: "lightgreen"
            anchors
            {
                top:topBar.bottom
                left:parent.left
                right:parent.right
                bottom:indicator.top
            }

            Rectangle
            {
                id:weekReport
                width:parent.width/1.20
                height:160
                color:"grey"
                radius:20
                anchors
                {
                    horizontalCenter: parent.horizontalCenter
                    top:parent.top
                    topMargin:10
                }
                Image
                {
                    id:streakIcon
                    source: "resourses/streak.png"
                    anchors
                    {
                        top: parent.top
                        left:parent.left
                        topMargin: 15
                        leftMargin: 15
                    }

                }
                Text
                {
                    id:dayCountStreak
                    text:"2"
                    font.pixelSize: 25
                    font.bold: true
                    anchors.left: streakIcon.right
                    anchors.top:streakIcon.top
                }

                Text
                {
                    text:"Day Streak"
                    font.pixelSize: 15
                    font.bold: true
                    anchors.top:dayCountStreak.bottom
                    anchors.topMargin: -5
                    anchors.left:dayCountStreak.left
                }

                Rectangle
                {
                    id:weekDaysStreak
                    width: 135
                    height:70
                    radius:25
                    color:"transparent"
                    anchors
                    {
                        top:streakIcon.bottom
                        topMargin:15
                        horizontalCenter:parent.horizontalCenter
                    }

                    //streak status of this week
                    Row {
                        spacing: 0
                        anchors {
                            top: parent.top
                            topMargin: 20
                            horizontalCenter: parent.horizontalCenter
                        }



                        Repeater {
                            model: days.length
                            delegate: Rectangle {
                                width: 60
                                height: 45
                                color: "transparent"

                                Rectangle {
                                    width: 35
                                    height: 35
                                    color: statuses[index] === 1 ? "blue" : "lightgray"
                                    radius: 35
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: days[index]
                                        color: statuses[index] === 1 ? "blue" : "lightgray"
                                        font.pixelSize: 15
                                        font.bold: true
                                        anchors.top: parent.top
                                        anchors.topMargin: -20
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Image {
                                        source: "resourses/check.png"
                                        width: 20
                                        height: 20
                                        anchors.centerIn: parent
                                        visible: statuses[index] === 1
                                    }
                                }
                            }
                        }
                    }

                }
            }


            Rectangle {
                id:tableList
                width: parent.width / 1.20
                height: 450
                color: "white"
                radius:20
                anchors {
                    top: weekReport.bottom
                    topMargin: 25
                    bottom: indicator.top
                    horizontalCenter: parent.horizontalCenter
                }

                Flickable {
                    id: flickable
                    anchors.fill: parent
                    contentWidth: grid.width
                    contentHeight: grid.height
                    flickableDirection: Flickable.VerticalFlick
                    clip: true

                    Grid {
                        id: grid
                        columns: Math.floor(flickable.width / (100 + spacing))
                        spacing: 15
                        width: flickable.width
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater
                        {
                            model: gridModel // Set number of items
                            Rectangle
                            {
                                width: 150
                                height: 80
                                color: "lightblue"
                                border.color: "gray"
                                radius: 20
                                Image {
                                    id:image
                                    source: modelData.t_icon
                                    width: 45
                                    height: 45
                                    fillMode: Image.PreserveAspectFit
                                    anchors
                                    {
                                        left:parent.left
                                        verticalCenter:parent.verticalCenter
                                    }
                                }
                                Text {
                                    text: modelData.t_title
                                    font.pixelSize: 15
                                    font.bold:true
                                    anchors
                                    {
                                        centerIn:parent
                                        // horizontalCenter:parent.horizontalCenter
                                        // top:parent.top
                                        // topMargin:20
                                    }
                                }
                                Text
                                {
                                    text:modelData.t_type
                                    anchors
                                    {
                                        bottom:parent.bottom;
                                        bottomMargin:10
                                        right:parent.right
                                        rightMargin:10
                                    }
                                }

                                MouseArea
                                {
                                    anchors.fill: parent
                                    onClicked:
                                    {
                                        // console.log("on item",modelData.t_title," clicked")

                                        backend.switchTable(modelData.t_title,modelData.t_type)

                                        if(modelData.t_type==="verb")
                                            mainStackView.push("PracticeVerbs.qml")
                                        else
                                            mainStackView.push("PracticePage.qml")
                                    }
                                }
                            }//-----
                        }
                    }
                }


            }


        }

        Rectangle
        {
            id:indicator
            width:parent.width
            height:75
            color:"pink"
            anchors.bottom: parent.bottom


            Row
            {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height:parent.height
                spacing: 10

                Rectangle
                {
                    width:70
                    height:parent.height
                    color:"black"
                    CustomButtonWithIcon
                    {
                        setButtonText:"Browse";
                        setButtonBorderColor: "transparent";
                        setIconSource:  "resourses/streak.png"
                        onButtonClicked:
                        {
                            mainStackView.push("BrowsePage.qml")
                        }
                    }
                }
                Rectangle
                {
                    width:70
                    height:parent.height
                    color:"black"
                    CustomButtonWithIcon
                    {
                        setButtonText:"Manage";
                        setButtonBorderColor: "transparent";
                        setIconSource:  "resourses/check.png"
                        onButtonClicked:
                        {
                            mainStackView.push("ManageWordTableDatabasePage.qml")
                        }
                    }
                }
                Rectangle
                {
                    width:70
                    height:parent.height
                    color:"black"
                    CustomButtonWithIcon
                    {
                        setButtonText:"Profile";
                        setButtonBorderColor: "transparent";
                        setIconSource:  "resourses/streak.png"
                        onButtonClicked:
                        {
                            mainStackView.push("ProfilePage.qml")
                        }
                    }
                }

                Rectangle
                {
                    width:70
                    height:parent.height
                    color:"black"
                    CustomButtonWithIcon
                    {
                        setButtonText:"Settings";
                        setButtonBorderColor: "transparent";
                        setIconSource:  "resourses/streak.png"
                        onButtonClicked:
                        {
                            mainStackView.push("SettingsPage.qml")
                        }
                    }
                }

            }

        }





    }

    function sqliteListToModel(sqliteList)
    {
        //get currentDatabase name
        var cDatabaseName = backend.whatIsCurrentDatabase();

        var model = [];
        for(var i = 0; i < sqliteList.length; i++)
        {
            if(sqliteList[i]===cDatabaseName)
                comboboxDatabases.currentIndex = i;

            model.push({
                           text: sqliteList[i],
                           icon: "resourses/streak.png" //dont want icon now
                       });
        }
        return model;
    }
    Component.onCompleted:
    {
        refresh()
    }

    Connections
    {
        target:backend
        function onTablesList(tables)
        {
            gridModel = tables;
            // console.log("gridModel =", JSON.stringify(gridModel));
        }
    }
    Connections {
        target: root
        //to refresh homePage when mainStack cameback to homePage
        onRefreshHomePageRequested: {
            refresh();
        }
    }

}
