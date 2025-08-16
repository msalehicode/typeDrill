import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Window
{
    id:root
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
                iconButton.text="<"
            else
            {
                iconButton.text="="

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


                    Rectangle{
                        width:parent.width;
                        height:50
                        color:"transparent"
                        CustomButton
                        {
                            setButtonText:"profile";
                            setButtonBorderColor: "purple";
                            setButtonBackColor:"white"
                            setButtonFontColor: "purple"
                            setButtonsBorderWidth: 5
                            onButtonClicked:
                            {
                                mainStackView.push("ProfilePage.qml")
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
    color:"orange"
    anchors.left: parent.left
    Text
    {
        id:iconButton
        text:"="
        anchors.centerIn: parent
        font.pixelSize: 40
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




}
