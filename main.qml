import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "./themes.js" as ThemeConfig

Window
{
    id:rootWindow
    width: 720
    height: 1600
    visible: true
    title: qsTr("TypeDrill")
    color:"#222424"
    onClosing:
    {
        if(mainStackView.depth>1)
        {
            mainStackView.pop();
            close.accepted = false;
        }

    }



    //theme colors
    QtObject
    {
        id:appColors;
        property string c_theme : "light";
        property var currentTheme: ThemeConfig.themeLight

        property color c_background : currentTheme["background"];
        property color c_bg_weekReport : currentTheme["bg_weekReport"];
        property color c_fontcolor : currentTheme["fontColor"];

        //day streak
        property color c_dayStreakCompleted: currentTheme["dayStreak_completed"];
        property color c_dayStreakMissed : currentTheme["dayStreak_missed"];
        property color c_dayStreakUnkown : currentTheme["dayStreak_unknown"];

        property color c_bg_tableList : currentTheme["bg_tableList"];
        property color c_bg_searchTableList : currentTheme["bg_searchTableList"];

        //buttons
        property color c_buttonBorderColor : currentTheme["buttons_borderColor"];
        property color c_buttonBgColor : currentTheme["buttons_bgColor"];
        property color c_buttonFontColor : currentTheme["buttons_fontColor"];


        property color c_tableList_itemBg : currentTheme["tableList_ItemBg"];
        property color c_tableList_itemBorder : currentTheme["tableList_ItemBorder"];

        property color c_bgIndicator : currentTheme["bg_indicator"];
    }

    QtObject
    {
        id:appFontSizes;
        property int f_title:  ThemeConfig.fontSizes["title"];

        property int f_large:  ThemeConfig.fontSizes["large"];
        property int f_normal: ThemeConfig.fontSizes["normal"];
        property int f_small:  ThemeConfig.fontSizes["small"];

        property int f_textInput:  ThemeConfig.fontSizes["Textinput"];
        property int f_buttonFontSize:  ThemeConfig.fontSizes["buttonsfontSize"];

    }

    QtObject
    {
        id:appIcons;
        property string i_path: "resourses/" + appColors.c_theme+"Mode/50x50/";


        property string icon_menubar: appIcons.i_path+ "menu.png";
        property string icon_back: appIcons.i_path+ "back.png";


        //tableList
        property string icon_pinned: appIcons.i_path + "pin.png";

        //day(s) streak and week report
        property string icon_streak: appIcons.i_path  + "streak.png";
        property string icon_close: appIcons.i_path + "close.png";
        property string icon_check: appIcons.i_path + "check.png";
        property string icon_question: appIcons.i_path + "question.png";


        //indicator icons
        property string icon_browse: appIcons.i_path + "browse.png";
        property string icon_profile: appIcons.i_path + "profile.png";
        property string icon_manage: appIcons.i_path + "manage.png";
        property string icon_settings: appIcons.i_path + "settings.png";

    }



    signal refreshHomePageRequested()

    StackView
    {
        id:mainStackView;
        initialItem: "./HomePage.qml";
        anchors.fill:parent;
        onPopExitChanged:
        {
            currentPageIndex=1;
        }
        onDepthChanged:
        {
            if(mainStackView.depth>1)
                imgBackOrMenu.source = appIcons.icon_back
            else
            {
                imgBackOrMenu.source = appIcons.icon_menubar

                refreshHomePageRequested();
            }
        }

    }

    Drawer
    {
        id: drawer;
        width: parent.width/2// 0.66 * parent.width;
        height: parent.height;
        ListView
        {
            id: listView
            focus: true
            currentIndex: -1
            anchors.fill: parent

            Rectangle
            {
                width:parent.width
                height:parent.height
                color:"black"

                Column
                {
                    width:parent.width
                    height:parent.height
                    spacing: 25


                    CustomButton
                    {
                        setButtonText:"profile";
                        setButtonBorderColor: "purple";
                        setButtonBackColor:"white"
                        setButtonFontColor: "purple"
                        setButtonsBorderWidth: 5
                        bwidth: parent.width
                        bheight: 50
                        onButtonClicked:
                        {
                            mainStackView.push("ProfilePage.qml")
                            drawer.close()
                        }
                    }
                    Rectangle{
                        width:parent.width;
                        height:50
                        color:"transparent"
                        CustomButton
                        {
                            setButtonText:"manage word/table/database";
                            setButtonBorderColor: "transparent";
                            onButtonClicked:
                            {
                                mainStackView.push("ManageWordTableDatabasePage.qml")
                                drawer.close()
                            }
                        }
                    }

                    Rectangle{
                        width:parent.width;
                        height:50
                        color:"transparent"
                        CustomButton
                        {
                            setButtonText:"settings";
                            setButtonBorderColor: "transparent";
                            onButtonClicked:
                            {
                                mainStackView.push("SettingsPage.qml")
                                drawer.close()
                            }
                        }
                    }

                    Rectangle{
                        width:parent.width;
                        height:50
                        color:"transparent"
                        CustomButton
                        {
                            setButtonText:"about";
                            setButtonBorderColor: "transparent";
                            onButtonClicked:
                            {
                                mainStackView.push("SettingsPage.qml")
                                drawer.close()
                            }
                        }
                    }

                }

            }

        }

        ScrollIndicator.vertical: ScrollIndicator { }
    }





Rectangle
{
    id:buttonBackOrDrawer
    width:50
    height:50
    color:"transparent"
    anchors.left: parent.left

    Image {
        id: imgBackOrMenu
        source: appIcons.icon_menubar
    }

    MouseArea
    {
        anchors.fill: parent
        onClicked:
        {
            if(mainStackView.depth>1)
                mainStackView.pop()
            else
                drawer.open()
        }
    }
}




    function reloadTheme()
    {
        const rs_theme = backend.getThemeMode();
        if(rs_theme === "light" || rs_theme === "dark")
        {
            if(rs_theme === appColors.c_theme)
                return;

            if(rs_theme === "light")
            {
                appColors.currentTheme = ThemeConfig.themeLight;
                appColors.c_theme = "light";
            }
            else
            {
                appColors.currentTheme = ThemeConfig.themeDark;
                appColors.c_theme = "dark";
            }
            console.log("theme="+appColors.c_theme, "icon pack=",JSON.stringify(appColors.currentTheme, null, 2))
        }
    }

    Component.onCompleted:
    {
        reloadTheme();
    }
}
