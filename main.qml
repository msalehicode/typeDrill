import QtQuick
import QtQuick.Controls
import "CustomComponents"

import "./themes.js" as ThemeConfig

Window
{
    id:rootWindow
    width: 412
    height: 776
    visible: true
    title: "TypeDrill Application"
    color:appColors.c_background
    
    //in some pages user have to wait for result, e.g network upload/download
    //so need to blockBackButton to avoid any problem
    property bool appBlockBackButton: false


    //make top icon (menu bar/back) controlable by other pages if source(icon)===menubar2
    property bool appVisibleBackOrMenuButton : true
    
    //android keyboard check, if its open some elemnts if needed change height or anchors...
    // property bool appKeyboardVisible: Qt.inputMethod.visible
    // property real appKeyboardHeight: Qt.inputMethod.keyboardRectangle.height
    onWidthChanged:
    {
        backend.setLastWindowSize("w",width);
    }
    onHeightChanged:
    {
        backend.setLastWindowSize("h",height);
    }
    
    onClosing:
    {
        if(appBlockBackButton)
            close.accepted = false;
        else if(mainStackView.depth>1)
        {
            mainStackView.pop();
            close.accepted = false;
        }
    }

    readonly property var appPracticeTypesList: Object.freeze({
                                                         typePractice: 1,
                                                         flashcardPractice: 2
                                                     })


    //store some variables to avoid multiple defines
    QtObject
    {
        id:appGlobalValues
        property var weekDays: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    }

    //theme colors
    QtObject
    {
        id:appColors;
        property string c_theme : "light";
        property var currentTheme: ThemeConfig.themeLight
        
        
        //main colors
        property color c_background : currentTheme["background"];
        property color c_headerBg : currentTheme["headerBg"];
        property color c_fontcolor : currentTheme["fontColor"];
        
        
        //day streak
        property color c_bg_weekReport : currentTheme["bg_weekReport"];
        property color c_dayStreakCompleted: currentTheme["dayStreak_completed"];
        property color c_dayStreakMissed : currentTheme["dayStreak_missed"];
        property color c_dayStreakUnkown : currentTheme["dayStreak_unknown"];
        property color c_weekdayBordercolor: currentTheme["weekDayBordercolor"];
        
        
        //practice table list
        property color c_bg_tableList : currentTheme["bg_tableList"];
        property color c_bgTableitem : currentTheme["bg_tableItem"];
        property color c_bgIcon_tableItem : currentTheme["bgIcon_tableItem"];
        property color c_borderColorIcon_tableItem : currentTheme["borderColorIcon_tableItem"];
        property color c_borderColorTextInput : currentTheme["borderColorTextInput"];
        
        //buttons
        property color c_buttonBorderColor : currentTheme["buttons_borderColor"];
        property color c_buttonBgColor : currentTheme["buttons_bgColor"];
        property color c_buttonFontColor : currentTheme["buttons_fontColor"];
        property color c_buttonCancelBgColor : currentTheme["button_cancelBgColor"];
        property color c_buttonCancelFontColor : currentTheme["button_cancelFontColor"];

        //combobox
        property color c_comboboxBgColor : currentTheme["combobox_bgColor"];
        property color c_comboboxBgColorCurrentItem : currentTheme["combobox_bgColorCurrentItem"];
        
        
        //textinput
        property color c_bgColor_textinput : currentTheme["bgColor_textinput"];
        property color c_borderColor_textinput : currentTheme["borderColor_textinput"];
        property color c_fontColor_textinput : currentTheme["fontColor_textinput"];
        
        
        //popup
        property color c_bgPopupContentFailed : currentTheme["bgPopupContentFailed"];
        property color c_bgPopupContentSuccess : currentTheme["bgPopupContentSuccess"];
        property color c_bgPopupContentDefault : currentTheme["bgPopupContentDefault"];
        
        //collapsible panel
        property color c_collapsContentBgColor: currentTheme["collapsContentBgColor"]

        //indicator
        property color c_bgIndicator : currentTheme["bg_indicator"];
    }
    
    QtObject
    {
        id:appFontSizes;
        property int f_mega: ThemeConfig.fontSizes["mega"];
        property int f_title:  ThemeConfig.fontSizes["title"];
        
        
        property int f_large:  ThemeConfig.fontSizes["large"];
        property int f_normal: ThemeConfig.fontSizes["normal"];
        property int f_small:  ThemeConfig.fontSizes["small"];
        
        
        property int f_textInput:  ThemeConfig.fontSizes["Textinput"];
        property int f_buttonFontSize:  ThemeConfig.fontSizes["buttonsfontSize"];
        
    }


    QtObject
    {
        id:appSettings;
        property bool autoPlayAudioOnPractice:true;
    }
    
    QtObject
    {
        id:appIcons;

        property string i_path: "resourses/" + appColors.c_theme+"Mode/50x50/";
        property string i_path_white: "resourses/darkMode/50x50/";
        
        //main.qml
        property string icon_menubar: appIcons.i_path+ "menu.png";
        property string icon_menubar2: appIcons.i_path + "menubar.png"
        property string icon_back: appIcons.i_path+ "back.png";
        property string icon_back_white: i_path_white +"back.png"; //only white
        
        
        //homePage
        property string icon_search: appIcons.i_path + "search.png";
        property string icon_search_white: i_path_white + "search.png"; //only white



        property string icon_archive: appIcons.i_path + "archive.png"
        property string icon_eye: appIcons.i_path + "eye.png"
        property string icon_hide: appIcons.i_path + "hide.png"


        property string icon_play: appIcons.i_path + "play.png"
        property string icon_pause: appIcons.i_path + "pause.png"

        //practice tableList
        property string icon_pinned: appIcons.i_path + "pin.png";
        
        //day(s) streak and week report
        property string icon_streak: appIcons.i_path  + "streak.png";
        property string icon_close: appIcons.i_path + "close.png";
        property string icon_check: appIcons.i_path + "check.png";
        property string icon_question: appIcons.i_path + "question.png";
        
        //browse
        property string icon_download: appIcons.i_path + "download.png"
        property string icon_upload: appIcons.i_path + "upload.png"
        
        //indicator icons
        property string icon_browse: appIcons.i_path + "browse.png";
        property string icon_profile: appIcons.i_path + "profile.png";
        property string icon_manage: appIcons.i_path + "manage.png";
        property string icon_settings: appIcons.i_path + "settings.png";
        
        //settings
        property string icon_save: appIcons.i_path + "save.png";
        property string icon_save_white: i_path_white + "save.png"; //only white
        

        property string icon_delete: appIcons.i_path + "delete.png"
        property string icon_modify: appIcons.i_path+ "modify.png"


        property string icon_turn : appIcons.i_path + "turn.png"
        property string icon_skip : appIcons.i_path + "skip.png"
        property string icon_signout : appIcons.i_path + "signout.png"
    }
    
    
    
    signal refreshHomePageRequested()
    

    StackView {
        id: mainStackView
        anchors.fill: parent
        initialItem: "HomePage.qml" // Replace this with the actual page

        // Handle when depth changes (when navigating between pages)
        onDepthChanged: {
            if (mainStackView.depth > 1) {
                buttonBackOrDrawer.modifyIcon(appIcons.icon_back, 20, 20)
            } else {
                buttonBackOrDrawer.modifyIcon(appIcons.icon_menubar2, 50, 50)
                refreshHomePageRequested()
            }
        }

        // Custom transition for push and pop actions
        transitions: Transition {
            from: "*"
            to: "*"
            reversible: true

            // Push transition: Fade and slide from right to left
            ParallelAnimation {
                NumberAnimation {
                    target: stackViewItem // Transition applied to the items within the stack
                    properties: "opacity"
                    to: 1
                    duration: 500
                }
                NumberAnimation {
                    target: stackViewItem
                    properties: "x"
                    to: 0
                    duration: 500
                }
            }

            // Pop transition: Fade and slide out to the right
            ParallelAnimation {
                NumberAnimation {
                    target: stackViewItem
                    properties: "opacity"
                    to: 0
                    duration: 500
                }
                NumberAnimation {
                    target: stackViewItem
                    properties: "x"
                    to: 400
                    duration: 500
                }
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
                        setWidth: parent.width
                        setHeight: 50
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
    
    
    
    
    
    
    
    CustomButtonWithIcon
    {
        id:buttonBackOrDrawer
        setButtonText:"";
        setIconSource: appIcons.icon_menubar2
        setButtonBorderColor: "transparent"
        setButtonBackColor: "transparent"
        setButtonFontColor: "transparent"
        setIconWidth: 50
        setIconHeight: 50
        setButtonsBorderWidth: 0
        setVisible: buttonBackOrDrawer.setIconSource === appIcons.icon_menubar2 ? true : appVisibleBackOrMenuButton
        setRadius: 50
        setWidth: 50
        setHeight:50
        anchors
        {
            left: parent.left
            leftMargin:5
            top:parent.top
            topMargin:5
        }
        onButtonClicked:
        {
            if(buttonBackOrDrawer.setIconSource === appIcons.icon_menubar2)
                drawer.open()
            else
                popStack()
        }
    }
    
    function popStack()
    {
        mainStackView.pop()
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
            // console.log("theme="+appColors.c_theme, "icon pack=",JSON.stringify(appColors.currentTheme, null, 2))


        }
    }
    
    Component.onCompleted:
    {
        reloadTheme();

        rootWindow.width = backend.getLastWindowSize("w");
        rootWindow.height = backend.getLastWindowSize("h");

        //manually reload icon
        //often it's color is default theme since loading, doesn't change with theme at start
        buttonBackOrDrawer.modifyIcon(appIcons.icon_menubar2)


        //get settings
        appSettings.autoPlayAudioOnPractice = backend.getSetting("autoPlayAudioOnPractice")==="true" ? true : false;
        console.log("setting autoPlayAudioOnPractice=",appSettings.autoPlayAudioOnPractice)
    }
}
