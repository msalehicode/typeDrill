import QtQuick
import QtQuick.Controls

Item
{
    width: setWidth
    height: setHeight

    property int setAnimationDuration:150;
    property int setBorderWidth: 6;
    signal switchSignalClicked;

    property int setWidth:50
    property int setHeight: 40
    property color setBgColorActivated: "blue"
    property color setBgColorDeactivated: "grey"

    property bool switchStatus:false;
    property bool setStatusBorder:true;
    property double setSizeSwitchCircle: 3.80;
    Rectangle
    {
        id:mySwitsch;
        width:  setWidth;
        height: setWidth/1.80;
        radius:50;
        color:switchStatus<=0? setBgColorDeactivated: setBgColorActivated;
        Rectangle
        {
            id:switchCircle;
            width: parent.width/setSizeSwitchCircle;
            height: width;
            color:cUnknown;
            radius:50;
            anchors.verticalCenter: parent.verticalCenter;
            x:switchStatus<=0? mySwitsch.width/8: mySwitsch.width/1.90;
//            y:setSwitchWidth/7;
        }
        border.width: setStatusBorder<=0? 0:setBorderWidth;
        border.color: setStatusBorder<=0? cBG_Unknown:cUnknown;
        MouseArea
        {
            anchors.fill: parent;
            onClicked:
            {
                if(switchCircle.x>mySwitsch.width/5) //switchStatus)
                {
                    animactionDeactive.running=true;
                    mySwitsch.color = setBgColorDeactivated;
                    switchStatus=false;
                    switchSignalClicked();
                }
                else
                {
                    animationAcvite.running=true;
                    mySwitsch.color = setBgColorActivated;
                    switchStatus=true;
                    switchSignalClicked();
                }


            }
        }

    }
    SequentialAnimation
    {
        id:animationAcvite;
        running:false;
        NumberAnimation
        {
            target: switchCircle;
            property: 'x';
            to:mySwitsch.width/1.90;
            duration: setAnimationDuration;
        }
    }
    SequentialAnimation
    {
        id:animactionDeactive;
        running:false;
        NumberAnimation
        {
            target: switchCircle;
            property: 'x';
            to:mySwitsch.width/8;
            duration: setAnimationDuration;
        }
    }

}
