import QtQuick
import QtQuick.Controls
import "CustomComponents"

Page
{
    id:homePage
    property ListModel statusesModel: ListModel
    {
        ListElement{status:"0"}
        ListElement{status:"1"}
        ListElement{status:"?"}
        ListElement{status:"?"}
        ListElement{status:"?"}
        ListElement{status:"?"}
        ListElement{status:"?"}
    }

    //tables list
    property var gridModel: []

    Rectangle
    {
        anchors.fill: parent;
        color:appColors.c_background

        CustomComboboxWithIcon
        {
            id: comboboxDatabases
            setBgColor: appColors.c_comboboxBgColor
            setFontColor: appColors.c_buttonFontColor
            setBgColorCurrentItem: appColors.c_comboboxBgColorCurrentItem
            setIconArrow: appIcons.icon_back_white
            setfontSize: appFontSizes.f_normal
            setRadius: 10
            setWidth: 180
            setHeight: 50
            anchors
            {
                right:parent.right
                rightMargin:15
                top:parent.top
                topMargin:5
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



        Rectangle
        {
            id:baseContentHomePage
            color: "transparent"
            anchors
            {
                top:comboboxDatabases.bottom
                left:parent.left
                right:parent.right
                bottom:indicator.top
            }

            Rectangle
            {
                id:weekReport
                width:parent.width/1.15
                height:140
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
                    color:appColors.c_background
                    radius:50
                    anchors
                    {
                        top: parent.top
                        right:parent.right
                        topMargin: 15
                        rightMargin: 15
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
                            leftMargin:12
                        }
                    }
                }


                Text
                {
                    id:todayDateLable
                    text: getFormattedDate()
                    font.pixelSize: appFontSizes.f_large
                    font.bold: true
                    color: appColors.c_fontcolor
                    anchors
                    {
                        top: parent.top
                        left:parent.left
                        topMargin: 20
                        leftMargin: 20
                    }
                }

                Rectangle
                {
                    id:weekDaysStreak
                    width: parent.width/1.10
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
                        spacing: parent.width/50
                        anchors.fill: parent
                        // leftPadding: parent.width/50
                        Repeater {
                            model: statusesModel
                            delegate: Rectangle {
                                width: parent.width/7.75
                                height: 40
                                color: "transparent"

                                Rectangle {
                                    width: 35
                                    height: 35
                                    color: model.status === "1" ? appColors.c_dayStreakCompleted : (model.status==="0") ? appColors.c_dayStreakMissed : appColors.c_dayStreakUnkown
                                    radius: 35
                                    border.color: appColors.c_weekdayBordercolor
                                    border.width: 3
                                    anchors.verticalCenter: parent.verticalCenter
                                    Image {
                                        source: model.status === "1" ? appIcons.icon_check : (model.status==="0") ? appIcons.icon_close: appIcons.icon_question
                                        width: 20
                                        height: 20
                                        anchors.centerIn: parent
                                    }



                                    Text {
                                        // text: appGlobalValues.weekDays[index]
                                        text: typeof appGlobalValues.weekDays[index] !== "undefined" ? appGlobalValues.weekDays[index] : ""
                                        color: model.status === "1" ? appColors.c_dayStreakCompleted : (model.status==="0") ? appColors.c_dayStreakMissed : appColors.c_dayStreakUnkown
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
                width:parent.width/1.15
                height:60
                color: appColors.c_bg_tableList
                radius:90
                anchors
                {
                    top:weekReport.bottom
                    topMargin: 15
                    horizontalCenter: parent.horizontalCenter
                }
                CustomSwitchText
                {
                    id:switchLearnPractice
                    setWidth:parent.width
                    setHeight:parent.height
                    setRadius: parent.radius
                    setBgColor: appColors.c_bg_tableList
                    setSwitchColor: appColors.c_buttonBgColor
                    setSwitchOpacity: 0.5
                    setFontColor:appColors.c_fontcolor
                    setFontSize: appFontSizes.f_normal
                    setRighttText:"Learn"
                    setLeftText: "Practice"
                    switchStatus: false
                    anchors.centerIn: parent
                    onSwitchClicked:
                    {
                        console.log("switchClicked");
                        if(switchStatus)
                        {
                            console.log("switch to learn")
                            //fetch tables/decks
                            backend.getTables(searchTableTextInput.theText,
                                              searchTableTypeCombobox.currentItemText);
                        }
                        else
                        {
                            console.log("switch to practice")
                            //fetch tables/decks
                            backend.getTables(searchTableTextInput.theText,
                                              searchTableTypeCombobox.currentItemText);
                        }

                    }

                }

            }

            Rectangle {
                id:tableList
                width:parent.width/1.15
                height:parent.height/1.75
                color: appColors.c_bg_tableList
                radius:30
                clip:true
                anchors
                {
                    top: selectPracticeOrEtc.bottom
                    topMargin: 15
                    horizontalCenter: parent.horizontalCenter
                }

                Rectangle
                {
                    id:searchBoxTableList
                    width:parent.width/1.10
                    height:60
                    color:"transparent"
                    // clip:true
                    anchors
                    {
                        horizontalCenter: parent.horizontalCenter
                        top:parent.top
                        topMargin:15
                    }

                    Row
                    {
                        spacing:3
                        width:parent.width
                        height:parent.height
                        anchors.horizontalCenter: parent.horizontalCenter
                        CustomTextInput
                        {
                            id:searchTableTextInput
                            setWidth: parent.width/1.50
                            setHeight: 45
                            setBgColor: appColors.c_bgColor_textinput
                            setBordercolor: appColors.c_borderColor_textinput
                            setBorderWidth:2
                            setFontSize:appFontSizes.f_textInput
                            setFontColor: appColors.c_fontColor_textinput
                            setRadius:10
                            theText:""
                            setTitleText:"Search:"

                            onTheTextChanged:
                            {
                                refresh()
                            }
                        }

                        CustomCombobox
                        {
                            id: searchTableTypeCombobox
                            setBgColor: appColors.c_comboboxBgColor
                            setFontColor: appColors.c_buttonFontColor
                            setfontSize: appFontSizes.f_normal
                            setIconArrow: appIcons.icon_back_white
                            setWidth: 80
                            height:45
                            modelData: !switchLearnPractice.switchStatus ?
                                           [
                                              {text:"all"},{ text:"word"},
                                              {text:"verb"},{ text:"archives"}
                                           ]
                                         :
                                           [
                                               {text:"learn"}
                                               // ,{text:"archives"}
                                           ]
                            setBgColorCurrentItem: appColors.c_comboboxBgColorCurrentItem
                            onActivated: function(index)
                            {
                                currentIndex = index
                                refresh()
                            }
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
                    delegate:Rectangle
                    {
                        width:parent.width/1.10
                        height:60
                        color:appColors.c_bgTableitem
                        radius: 20
                        clip:true
                        anchors
                        {
                            horizontalCenter: parent.horizontalCenter
                        }

                        Rectangle
                        {
                            id:baseIconTable
                            width:35
                            height:35
                            color:appColors.c_bgIcon_tableItem
                            border.color: modelData.t_status === "pinned" ? appColors.c_borderColorIcon_tableItem : "transparent"
                            border.width: 3
                            radius:50
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 15
                            Image
                            {
                                source: modelData.t_icon ==="" ? appIcons.icon_question:  modelData.t_icon
                                width:25
                                height:25
                                anchors.centerIn: parent
                                onStatusChanged:
                                {
                                    if (status === Image.Error)
                                    {
                                        console.warn("Image failed to load:", source);
                                        source=appIcons.icon_question
                                    }
                                }
                            }
                        }

                        Rectangle
                        {
                            id:baseTableTitles
                            width:parent.width/1.60
                            height:parent.height/1.50
                            color:"transparent"
                            // anchors.centerIn: parent
                            anchors.left: baseIconTable.right
                            anchors.top: baseIconTable.top
                            // clip:true
                            Text
                            {
                                id:tableTitleText
                                width:parent.width/1.10
                                height:parent.height
                                wrapMode: Text.WordWrap
                                text: modelData.t_title
                                color:appColors.c_fontcolor
                                font.pixelSize: text.length>20 ? appFontSizes.f_small : appFontSizes.f_normal
                                font.bold:true
                                anchors
                                {
                                    left:parent.left
                                    leftMargin:10
                                    top:parent.top
                                    topMargin:7
                                    // horizontalCenter:parent.horizontalCenter
                                }
                            }
                        }


                        Rectangle
                        {
                            width:25
                            height:25
                            color:appColors.c_buttonBgColor
                            radius:50
                            rotation: 180
                            anchors
                            {
                                right:parent.right
                                rightMargin:10
                                verticalCenter:parent.verticalCenter
                            }
                            Image
                            {
                                source: appIcons.icon_back_white
                                width:parent.width/1.50
                                height:parent.height/1.50
                                anchors.centerIn: parent
                            }
                        }

                        MouseArea {
                            id:mAreaItem
                            anchors.fill: parent
                            onClicked:
                            {
                                backend.switchTable(modelData.t_title, modelData.t_type);

                                if(!switchLearnPractice.switchStatus )
                                {
                                    mainStackView.push("PracticePage.qml", { tableType: modelData.t_type, m_stackView: mainStackView});
                                }
                                else
                                {
                                    mainStackView.push("LearnPage.qml");
                                }

                            }
                            onPressAndHold:
                            {
                                popupMenu.openWhereOnClicked(mAreaItem,tableListView)

                                //add items into menu
                                if(modelData.t_status==="pinned")
                                    popupMenu.addItem("Unpin table",modelData.t_title,modelData.t_id,"unpin",appIcons.icon_pinned);
                                else
                                    popupMenu.addItem("Pin table",modelData.t_title,modelData.t_id,"pin",appIcons.icon_pinned);

                                if(modelData.t_status==="archived")
                                    popupMenu.addItem("Unarchive table",modelData.t_title,modelData.t_id,"unarchive", appIcons.icon_archive);
                                else
                                    popupMenu.addItem("Archive table",modelData.t_title,modelData.t_id,"archive", appIcons.icon_archive);

                                popupMenu.addItem("Rename table",modelData.t_title,modelData.t_id,"rename", appIcons.icon_modify);
                                popupMenu.addItem("Delete table",modelData.t_title,modelData.t_id,"delete", appIcons.icon_delete);

                            }
                        }

                    }

                }

                CustomPopupMenu
                {
                    id:popupMenu
                    setWidth:parent.width/1.10
                    setBgColor: appColors.c_background
                    setFontColor:appColors.c_fontcolor
                    setBgItemColor: appColors.c_comboboxBgColor
                    setFontSize: appFontSizes.f_normal
                    onItemClicked: function(tid,iaction,ttext)
                    {
                        var result;
                        switch(iaction)
                        {
                            case "pin":
                            {
                                result= backend.changeTableStatus(tid,"pin");
                                if (result !== "error")
                                    homePage.refresh();
                                else
                                    console.log("couldn't update table status result:", result);
                            }break;
                            case "unpin":
                            {
                                result = backend.changeTableStatus(tid,"unpin");
                                if (result !== "error")
                                    homePage.refresh();
                                else
                                    console.log("couldn't update table status result:", result);
                            }break;

                            case "delete":
                            {
                                buttonConfirmPopupMessage.setActionHandler(function()
                                {
                                    backend.deleteTable(ttext); //ttext is same tableName
                                    popupMessage.close();
                                });
                                popupMessage.open("Are you sure to delete table " + ttext + " ?")
                            }break;
                            case "rename":
                            {
                                buttonConfirmPopupMessageRename.setActionHandler( function()
                                {
                                    backend.renameTable(ttext,newNameTable.theText);
                                });
                                newNameTable.theText=ttext;
                                popupMessageRename.open()

                            }break;

                            case "archive":
                            {
                                buttonConfirmPopupMessage.setActionHandler(function()
                                {
                                    result = backend.changeTableStatus(tid,"archive");
                                    if (result !== "error")
                                        homePage.refresh();
                                    else
                                        console.log("couldn't update table status result:", result);

                                    popupMessage.close()
                                });
                                popupMessage.open("Are you sure to archive table " + ttext + " ?")
                            }break;

                            case "unarchive":
                            {
                                buttonConfirmPopupMessage.setActionHandler(function()
                                {
                                    result = backend.changeTableStatus(tid,"unarchive");
                                    if (result !== "error")
                                        homePage.refresh();
                                    else
                                        console.log("couldn't update table status result:", result);

                                    popupMessage.close()
                                });
                                popupMessage.open("Are you sure to unarchive table " + ttext + " ?")
                            }break;
                        }
                        popupMenu.close()
                    }
                }

                //end of listview

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
                height:60
                anchors
                {
                    left:parent.left
                    leftMargin: parent.width/10
                }

                CustomButtonWithIcon
                {
                    setWidth:70
                    setHeight:parent.height/1.25
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
                height:60
                anchors.left: baseBrowse.right
                CustomButtonWithIcon
                {
                    setWidth:70
                    setHeight:parent.height/1.25
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
                height:60
                anchors.left: baseManage.right
                CustomButtonWithIcon
                {
                    setWidth:70
                    setHeight:parent.height/1.25
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
                height:60
                anchors.left: baseProfile.right
                CustomButtonWithIcon
                {
                    setWidth:70
                    setHeight:parent.height/1.25
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
        setWidth: parent.width/1.50
        setHeight: 250


        Row
        {
            width:parent.width/2
            height:50
            spacing: 7
            anchors
            {
                horizontalCenter:parent.horizontalCenter
                bottom:parent.bottom
            }

            CustomButton
            {
                id:buttonCancelPopupMessage
                setButtonText:"Cancel";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonCancelBgColor
                setButtonFontColor: appColors.c_buttonCancelFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 70
                setHeight:50
                onButtonClicked:
                {
                    popupMessage.close()
                }
            }

            CustomButton
            {
                id:buttonConfirmPopupMessage
                setButtonText:"Confirm";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 70
                setHeight:50
                //actions will handle dynamically for each item by passing function to setActionHandler()
            }
        }

    }




    CustomPopupMessage
    {
        id:popupMessageRename
        setDefaultText: ""
        setFailColor: appColors.c_bgPopupContentFailed
        setSuccessColor:appColors.c_bgPopupContentSuccess
        setBgContent: appColors.c_bgPopupContentDefault
        setTextFontSize: appFontSizes.f_normal
        setTextColor:  appColors.c_fontcolor
        setBgColorPopup: appColors.c_background
        setWidth: parent.width/1.50
        setHeight: 250

        CustomTextInput
        {
            id:newNameTable
            setWidth: parent.width/1.25
            setHeight: 50
            setBgColor: appColors.c_bgColor_textinput
            setBordercolor: appColors.c_borderColor_textinput
            setBorderWidth:2
            setFontSize:appFontSizes.f_textInput
            setFontColor: appColors.c_fontColor_textinput
            setRadius:10
            theText:""
            setErrorPosfix: ""
            setErrorPrefix: ""
            setTitleText:"New Table Name:"
            anchors
            {
                centerIn:parent
            }
            onTheTextAccepted:
            {
                buttonConfirmPopupMessageRename.runActionHandler()
            }
        }



        Row
        {
            width:parent.width/2
            height:50
            spacing: 7
            anchors
            {
                horizontalCenter:parent.horizontalCenter
                bottom:parent.bottom
            }

            CustomButton
            {
                id:buttonCancelPopupMessageRename
                setButtonText:"Cancel";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonCancelBgColor
                setButtonFontColor: appColors.c_buttonCancelFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 70
                setHeight:50
                onButtonClicked:
                {
                    popupMessageRename.close()
                }
            }


            CustomButton
            {
                id:buttonConfirmPopupMessageRename
                setButtonText:"Rename";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 70
                setHeight:50
                //actions will handle dynamically for each item by passing function to setActionHandler()
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
        streakDays.shift(); //remove first element

        statusesModel.clear();
        for (var i = 0; i < streakDays.length; i++) {
            statusesModel.append({"status": streakDays[i]});
        }

        //fetch tables/decks
        backend.getTables(searchTableTextInput.theText,
                          searchTableTypeCombobox.currentItemText);
    }


    function getFormattedDate() {
        const now = new Date(); // Create a new Date object representing the current date and time

        // Get the day of the week (0 = Sunday, 1 = Monday, ..., 6 = Saturday)
        const daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        const dayOfWeek = daysOfWeek[now.getDay()];

        // Get the day of the month (1 to 31)
        const dayOfMonth = now.getDate();

        // Get the month (0 = January, 1 = February, ..., 11 = December)
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        const month = months[now.getMonth()];

        // Get the year
        // const year = now.getFullYear();

        // Format the result as you need
        return `${dayOfWeek}, ${dayOfMonth} ${month}`;
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
                           icon: appIcons.icon_question //dont want icon now
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
        function onTableRemovalResult(result)
        {
            if(result)
            {
                console.log("table deleted.")
                popupMessage.close()
                homePage.refresh();
            }

            else
                console.log("failed to delete table")
        }

        function onTableRenameResult(result)
        {
            if(result)
            {
                console.log("table renamed.")
                popupMessageRename.close()
                homePage.refresh();
            }

            else
                console.log("failed to rename table result=", result)
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
