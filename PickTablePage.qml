import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
Page
{
    property string routeTarget: "none"
    anchors.fill: parent
    Rectangle
    {
        color:"#222424"
        anchors.fill: parent
        Item
        {
            id:baseTablePicker
            anchors.centerIn: parent
            width:500;
            height:500;
            visible: true;
            ComboBox {
                id: tablesComboBox
                visible: true
                width: 200
                height: 30
                anchors.centerIn: parent
                model: ListModel {}

                // Important! Tell the ComboBox which role to use for display text:
                textRole: "text"
            }
            Button
            {
                id:buttonGo
                text:"select"
                anchors.top: tablesComboBox.bottom
                anchors.left: tablesComboBox.left
                onClicked:
                {
                    if(tablesComboBox.currentIndex>=0)
                    {
                        var selectedItem = tablesComboBox.model.get(tablesComboBox.currentIndex);
                        backend.switchTable(selectedItem.t_name,selectedItem.t_id);
                        mainStackView.push(routeTarget)
                    }
                }
            }
        }

    }


    Connections
    {
        target: backend
        function onTablesList(tables)
        {
            // console.log("Received tables list with", tables.length, "rows");
            for (var i = 0; i < tables.length; ++i)
            {
                var row = tables[i];
                // console.log("Row", i, "t_id:", row.t_id, "t_title:", row.t_title, "t_status:", row.t_status);
                tablesComboBox.model.append({
                        t_id: row.t_id,
                        t_name: row.t_title,
                        text: row.t_title,
                        value: row.t_status
                    });
            }
        }
    }

    Component.onCompleted:
    {
        //first time fetch data from backend
        if(routeTarget==="PracticeVerbs.qml")
            backend.getTables("verbs")
        else
            backend.getTables("all")
    }

}
