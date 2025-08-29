import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Page
{
    id:homePage
    anchors.fill: parent
    property var days: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    property ListModel statusesModel: ListModel {}

    //tables list
    property var gridModel: []

    Rectangle
    {
        anchors.fill: parent;
        color:appColors.c_background

        Rectangle
        {
            id:topBar
            width: parent.width
            height:55
            color :"transparent"
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
            color: "transparent"
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
                color:appColors.c_bg_weekReport
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
                    source: appIcons.icon_streak//"resourses/streak.png"
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
                    font.pixelSize: appFontSizes.f_title
                    font.bold: true
                    color: appColors.c_fontcolor
                    anchors.left: streakIcon.right
                    anchors.top:streakIcon.top
                }

                Text
                {
                    text:"Day Streak"
                    font.pixelSize: appFontSizes.f_normal
                    font.bold: true
                    color: appColors.c_fontcolor
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
                            model: statusesModel
                            delegate: Rectangle {
                                width: 60
                                height: 45
                                color: "transparent"

                                Rectangle {
                                    width: 35
                                    height: 35
                                    color: model.status === "1" ? appColors.c_dayStreakCompleted : (model.status==="0") ? appColors.c_dayStreakMissed : appColors.c_dayStreakc_dayStreakUnkown
                                    radius: 35
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        text: days[index]
                                        color: model.status === "1" ? appColors.c_dayStreakCompleted : (model.status==="0") ? appColors.c_dayStreakMissed : appColors.c_dayStreakc_dayStreakUnkown
                                        font.pixelSize: appFontSizes.f_normal
                                        font.bold: true
                                        anchors.top: parent.top
                                        anchors.topMargin: -20
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Image {

                                        source: model.status === "1" ? appIcons.icon_check : (model.status==="0") ? appIcons.icon_close: appIcons.icon_question
                                        width: 20
                                        height: 20
                                        anchors.centerIn: parent
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
                color: appColors.c_bg_tableList
                radius:20
                anchors {
                    top: weekReport.bottom
                    topMargin: 25
                    bottom: indicator.top
                    horizontalCenter: parent.horizontalCenter
                }

                Rectangle
                {
                    id:searchBoxTableList
                    width:parent.width
                    height:70
                    color:appColors.c_bg_searchTableList
                    TextInput
                    {
                        id:searchTableTextInput
                        text:""
                        color: appColors.c_fontcolor
                        font.pixelSize: appFontSizes.f_textInput
                        width:parent.width/1.10
                        height:parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        onAccepted:
                        {
                            refresh()
                        }
                    }

                    CustomButton
                    {
                        id:buttonSubmitSearch
                        setButtonText:"search";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor:appColors.c_buttonBgColor
                        setButtonFontColor: appColors.c_buttonFontColor
                        setButtonFontsize: appFontSizes.f_buttonFontSize
                        setButtonsBorderWidth: 5
                        bwidth: 150
                        bheight: 70
                        anchors.right:parent.right
                        anchors.top:parent.top
                        onButtonClicked:
                        {
                            refresh()
                        }
                    }

                    ComboBox
                    {
                        id:searchTableTypeCombobox
                        anchors.right: buttonSubmitSearch.left
                        anchors.top:parent.top
                        width:70
                        height:parent.height
                        model: ["all","verb","word","single"]
                        onCurrentTextChanged:
                        {
                            refresh()
                        }
                    }


                }

                Flickable {
                    id: flickable
                    // anchors.fill: parent
                    anchors
                    {
                        top:searchBoxTableList.bottom
                        left:parent.left
                        right: parent.right
                        bottom:parent.bottom
                    }

                    contentWidth: grid.width
                    contentHeight: grid.height
                    flickableDirection: Flickable.VerticalFlick
                    clip: true

                    Grid {
                        id: grid
                        columns: Math.floor(flickable.width / (200 + spacing))
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
                                color: appColors.c_tableList_itemBg
                                border.color: appColors.c_tableList_itemBorder
                                radius: 20
                                Image
                                {
                                    id:pinnedIcon
                                    source: modelData.t_status === "pinned" ? appIcons.icon_pinned : ""
                                    width: 45
                                    height: 45
                                    fillMode: Image.PreserveAspectFit
                                    anchors
                                    {
                                        right:parent.right
                                        top:parent.top
                                    }
                                }

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
                                    font.pixelSize: appFontSizes.f_normal
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
                                    font.pixelSize: appFontSizes.f_small
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
                                            mainStackView.push("PracticePage.qml", { practiceMode:"verb" })
                                        else
                                            mainStackView.push("PracticePage.qml", { practiceMode:"word" })
                                    }
                                    onPressAndHold:
                                    {
                                        var result = backend.pinTable(modelData.t_id);
                                        if(result==="table status has been updated.")
                                        {
                                            refresh();
                                        }
                                        else
                                            console.log("couldn't update pin status of table");
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
            color: appColors.c_bgIndicator
            anchors.bottom: parent.bottom


            Row
            {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                height:parent.height
                spacing: 10

                CustomButtonWithIcon
                {
                    bwidth:70
                    bheight:parent.height
                    setButtonText:"Browse";
                    setButtonBorderColor: "transparent";
                    setIconSource:  appIcons.icon_browse
                    onButtonClicked:
                    {
                        mainStackView.push("BrowsePage.qml")
                    }
                }


                CustomButtonWithIcon
                {
                    bwidth:70
                    bheight:parent.height
                    setButtonText:"Manage";
                    setButtonBorderColor: "transparent";
                    setIconSource:  appIcons.icon_manage
                    onButtonClicked:
                    {
                        mainStackView.push("ManageWordTableDatabasePage.qml")
                    }
                }

                CustomButtonWithIcon
                {
                    bwidth:70
                    bheight:parent.height
                    setButtonText:"Profile";
                    setButtonBorderColor: "transparent";
                    setIconSource:  appIcons.icon_profile
                    onButtonClicked:
                    {
                        mainStackView.push("ProfilePage.qml")
                    }
                }


                CustomButtonWithIcon
                {
                    bwidth:70
                    bheight:parent.height
                    setButtonText:"Settings";
                    setButtonBorderColor: "transparent";
                    setIconSource:  appIcons.icon_settings
                    onButtonClicked:
                    {
                        mainStackView.push("SettingsPage.qml")
                    }
                }

            }

        }





    }

    function refresh()
    {
        console.log("HomePage is refreshed!");


        //get currentDatabase name and fetch and set available databases
        var cDatabaseName = backend.whatIsCurrentDatabase();
        var filesNames = backend.listOfDatabases();
        comboboxDatabases.modelData = sqliteListToModel(filesNames,cDatabaseName);


        //fetch and set day streaks
        var streakDays = backend.getStreakDays();
        dayCountStreak.text = streakDays[0] //holds streak days number
        console.log("streakdays=",streakDays[0])
        streakDays.shift(); //remove first element

        statusesModel.clear();
        for (var i = 0; i < streakDays.length; i++) {
            statusesModel.append({"status": streakDays[i]});
        }

        //fetch tables/decks
        backend.getTables(searchTableTextInput.text,searchTableTypeCombobox.currentText);
    }

    function sqliteListToModel(sqliteList,currentDatabaseName="")
    {
        var model = [];
        for(var i = 0; i < sqliteList.length; i++)
        {
            if(sqliteList[i]===currentDatabaseName)
                comboboxDatabases.currentIndex = i;

            model.push({
                           text: sqliteList[i],
                           icon: appIcons.icon_streak //dont want icon now
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
