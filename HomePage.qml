import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

Page
{
    id:homePage
    anchors.fill: parent
    property var days: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    property ListModel statusesModel: ListModel
    {
        ListElement{status:"0"}
        ListElement{status:"0"}
        ListElement{status:"1"}
        ListElement{status:"1"}
        ListElement{status:"1"}
        ListElement{status:"?"}
        ListElement{status:"?"}
    }

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
                radius:30
                anchors
                {
                    horizontalCenter: parent.horizontalCenter
                    top:parent.top
                    topMargin:10
                }
                Rectangle
                {
                    width:70
                    height:40
                    color:"#EBEAFB"
                    radius:50
                    anchors
                    {
                        top: parent.top
                        right:parent.right
                        topMargin: 25
                        rightMargin: 25
                    }
                    Image
                    {
                        id:streakIcon
                        source: appIcons.icon_streak
                        width:25
                        height:25
                        anchors
                        {
                            verticalCenter:parent.verticalCenter;
                            right:parent.right
                            rightMargin:5
                        }
                    }
                    Text
                    {
                        id:dayCountStreak
                        text:"293"
                        font.pixelSize: appFontSizes.f_normal
                        font.bold: true
                        color: appColors.c_fontcolor
                        anchors
                        {
                            verticalCenter:parent.verticalCenter;
                            left:parent.left
                            leftMargin:15
                        }
                    }
                }


                Text
                {
                    id:todayDateLable
                    text:"Thu, 6 February"
                    font.pixelSize: appFontSizes.f_large
                    font.bold: true
                    color: appColors.c_fontcolor
                    anchors
                    {
                        top:parent.top
                        topMargin:25
                        left:parent.left
                        leftMargin:25
                    }
                }

                Rectangle
                {
                    id:weekDaysStreak
                    width: parent.width/1.25
                    height:70
                    radius:25
                    color:"transparent"
                    anchors
                    {
                        top:todayDateLable.bottom
                        topMargin:15
                        horizontalCenter:parent.horizontalCenter
                    }

                    //streak status of this week
                    Row {
                        spacing: 0
                        anchors {
                            top: parent.top
                            // topMargin: 20
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
                                    border.color: "#ebe9f2"
                                    border.width: 3
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        source: model.status === "1" ? appIcons.icon_check : (model.status==="0") ? appIcons.icon_close: appIcons.icon_question
                                        width: 20
                                        height: 20
                                        anchors.centerIn: parent
                                    }



                                    Text {
                                        text: days[index]
                                        color: model.status === "1" ? appColors.c_dayStreakCompleted : (model.status==="0") ? appColors.c_dayStreakMissed : appColors.c_dayStreakc_dayStreakUnkown
                                        font.pixelSize: appFontSizes.f_normal
                                        font.bold: true
                                        anchors
                                        {
                                            top: parent.bottom
                                            horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
            }


            Rectangle
            {
                id:selectPracticeOrEtc
                width: parent.width / 1.20
                height:70
                color: "#EBEAFB"
                radius:70
                anchors
                {
                    top:weekReport.bottom
                    topMargin: 25
                    horizontalCenter: parent.horizontalCenter
                }

                Row
                {
                    anchors.centerIn: parent
                    spacing:30
                    Button{
                        text:"practice"
                    }
                    Button{
                        text:"class"
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
                    top: selectPracticeOrEtc.bottom
                    topMargin: 35
                    bottom: indicator.top
                    horizontalCenter: parent.horizontalCenter
                }

                Rectangle
                {
                    id:searchBoxTableList
                    width:parent.width/1.10
                    anchors
                    {
                        horizontalCenter: parent.horizontalCenter
                        top:parent.top
                        topMargin:15
                    }
                    height:50
                    radius:50
                    color:appColors.c_bg_searchTableList
                    Rectangle
                    {
                        id:baseSearchInput
                        color:"transparent"
                        width:parent.width/1.50
                        height:parent.height
                        border.color:"black"
                        anchors
                        {
                            left:parent.left
                            leftMargin:25
                        }
                        radius:25
                        clip:true

                        TextInput
                        {
                            id:searchTableTextInput
                            text:""
                            color: appColors.c_fontcolor
                            font.pixelSize: appFontSizes.f_textInput
                            width:parent.width/1.10
                            height:parent.height/2
                            anchors.centerIn: parent
                            onAccepted:
                            {
                                refresh()
                            }
                        }
                    }

                    ComboBox
                    {
                        id:searchTableTypeCombobox
                        anchors.left: baseSearchInput.right
                        anchors.top:parent.top
                        width:70
                        height:parent.height
                        model: ["all","verb","word","single"]
                        onCurrentTextChanged:
                        {
                            refresh()
                        }
                    }

                    CustomButton
                    {
                        id:buttonSubmitSearch
                        setButtonText:"search";
                        setButtonBorderColor:appColors.c_buttonBorderColor
                        setButtonBackColor: appColors.c_buttonBgColor
                        setButtonFontColor: "white"
                        setBold: true
                        setButtonFontsize: appFontSizes.f_buttonFontSize
                        setButtonsBorderWidth: 0
                        setRadius: 20
                        bwidth: 70
                        bheight: 50
                        anchors
                        {
                            top:parent.top
                            right:parent.right
                        }
                        onButtonClicked:
                        {
                            refresh()
                        }
                    }




                }



                ListView {
                    id: tableListView
                    anchors {
                        top: searchBoxTableList.bottom
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                    }
                    model: gridModel
                    clip: true
                    spacing: 15
                    delegate:
                        Rectangle
                        {
                            width:parent.width/1.50
                            height:75
                            color:"white"
                            radius: 15
                            clip:true
                            anchors
                            {
                                horizontalCenter: parent.horizontalCenter
                            }

                            Rectangle
                            {
                                id:baseIconTable
                                width:50
                                height:50
                                color:"grey"
                                border.color: "yellow"
                                border.width: 1
                                radius:50
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                Image
                                {
                                    source: modelData.t_icon ==="" ? appIcons.icon_question :  modelData.t_icon
                                    width:45
                                    height:45
                                    anchors.centerIn: parent
                                }
                            }

                            Rectangle
                            {
                                id:baseTableTitles
                                width:parent.width/1.70
                                height:parent.height/1.20
                                color:"transparent"
                                anchors.centerIn: parent
                                clip:true
                                Text
                                {
                                    id:tableTitleText
                                    text: modelData.t_title
                                    color:appColors.c_fontcolor
                                    font.pixelSize: appFontSizes.f_large
                                    font.bold:true
                                    anchors.centerIn: parent
                                }


                                Text
                                {
                                    text:modelData.t_type
                                    font.pixelSize: appFontSizes.f_normal
                                    color:appColors.c_fontcolor

                                    anchors
                                    {
                                        top:tableTitleText.bottom
                                        horizontalCenter:parent.horizontalCenter
                                    }
                                }

                                Image
                                {
                                    source:appIcons.icon_pinned
                                    width:30
                                    height:30
                                    visible: modelData.t_status === "pinned" ? true : false
                                    anchors
                                    {
                                        top:tableTitleText.top
                                        left:tableTitleText.right
                                        leftMargin:5
                                    }
                                }
                            }


                            Rectangle
                            {
                                width:35
                                height:35
                                color:"#6f47d9"
                                radius:50
                                rotation: 180
                                anchors
                                {
                                    right:parent.right
                                    rightMargin:20
                                    verticalCenter:parent.verticalCenter
                                }
                                Image
                                {
                                    source: appIcons.icon_back
                                    width:parent.width/1.50
                                    height:parent.height/1.50
                                    anchors.centerIn: parent
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    backend.switchTable(modelData.t_title, modelData.t_type);
                                    if (modelData.t_type === "verb")
                                        mainStackView.push("PracticePage.qml", { practiceMode: "verb" });
                                    else
                                        mainStackView.push("PracticePage.qml", { practiceMode: "word" });
                                }
                                onPressAndHold: {
                                    var result = backend.pinTable(modelData.t_id);
                                    if (result === "table status has been updated.") {
                                        refresh();
                                    } else
                                        console.log("couldn't update pin status of table");
                                }
                            }

                        }
                }


            }


        }

        Rectangle
        {
            id:indicator
            width:parent.width
            height:80
            color: appColors.c_bgIndicator
            anchors.bottom: parent.bottom

            Rectangle
            {
                id:baseBrowse
                color:"transparent"
                width:parent.width/5
                height:100
                anchors
                {
                    left:parent.left
                    leftMargin: parent.width/10
                }

                CustomButtonWithIcon
                {
                    bwidth:70
                    bheight:parent.height/1.25
                    anchors.centerIn: parent
                    setButtonText:"Browse";
                    setButtonBorderColor: "transparent";
                    setButtonFontColor:appColors.c_fontcolor;
                    setButtonBackColor:"transparent"
                    setTextMagin: 5
                    setIconHeight: 35
                    setIconWidth: 35
                    setIconSource:  appIcons.icon_browse
                    onButtonClicked:
                    {
                        mainStackView.push("BrowsePage.qml")
                    }
                }
            }

            Rectangle
            {
                id:baseManage
                color:"transparent"
                width:parent.width/5
                height:100
                anchors.left: baseBrowse.right
                CustomButtonWithIcon
                {
                    bwidth:70
                    bheight:parent.height/1.25
                    setButtonText:"Manage";
                    setButtonBorderColor: "transparent";
                    setButtonFontColor:appColors.c_fontcolor;
                    setButtonBackColor:"transparent"
                    setTextMagin: 5
                    setIconHeight: 35
                    setIconWidth: 35
                    setIconSource:  appIcons.icon_manage
                    anchors.centerIn: parent
                    onButtonClicked:
                    {
                        mainStackView.push("ManageWordTableDatabasePage.qml")
                    }
                }
            }

            Rectangle
            {
                id:baseProfile
                color:"transparent"
                width:parent.width/5
                height:100
                anchors.left: baseManage.right
                CustomButtonWithIcon
                {
                    bwidth:70
                    bheight:parent.height/1.25
                    setButtonText:"Profile";
                    setButtonBorderColor: "transparent";
                    setButtonFontColor:appColors.c_fontcolor;
                    setButtonBackColor:"transparent"
                    setTextMagin: 5
                    setIconHeight: 35
                    setIconWidth: 35
                    setIconSource:  appIcons.icon_profile
                    anchors.centerIn: parent
                    onButtonClicked:
                    {
                        mainStackView.push("ProfilePage.qml")
                    }
                }
            }


            Rectangle
            {
                id:baseSettings
                color:"transparent"
                width:parent.width/5
                height:100
                anchors.left: baseProfile.right
                CustomButtonWithIcon
                {
                    bwidth:70
                    bheight:parent.height/1.25
                    setButtonText:"Settings";
                    setButtonBorderColor: "transparent";
                    setButtonFontColor:appColors.c_fontcolor;
                    setButtonBackColor:"transparent"
                    setTextMagin: 5
                    setIconHeight: 35
                    setIconWidth: 35
                    setIconSource:  appIcons.icon_settings
                    anchors.centerIn: parent
                    onButtonClicked:
                    {
                        mainStackView.push("SettingsPage.qml")
                    }
                }
            }
        }//-------indicator




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
        target: rootWindow
        //to refresh homePage when mainStack cameback to homePage
        onRefreshHomePageRequested: {
            refresh();
        }
    }

}
