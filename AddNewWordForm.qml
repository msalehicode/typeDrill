import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

Page
{
    id:addNewWordForm
    anchors.fill: parent
    property string formType: "none"


    onFormTypeChanged:
    {
        if(formType=="word")
        {
            //text, meaning, example, translate, source, status

        }
        else if(formType=="verb")
        {
            //verb, past, past perfect, status
            fifthInput.enabled=false;
            fifthInput.visible=false;
            sixthInput.visible=false;
            sixthInput.enabled=false;
            rec5.visible=false;
            rec6.visible=false;
        }
        else if(formType=="single")
        {
           forthInput.visible=false;
            fifthInput.visible=false;
            sixthInput.visible=false;
            rec4.visible=false;
            rec5.visible=false;
            rec6.visible=false;
        }
    }

    Rectangle
    {
        id:baseSelectTable
        color:"#222424"
        anchors.fill: parent
        visible: true

        ComboBox {
            id: tablesComboBox
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
                    backend.switchTable(selectedItem.t_name,selectedItem.t_type);
                    formType = selectedItem.t_type
                    baseForm.visible=true
                    baseSelectTable.visible=false
                }
            }
        }
    }

    Rectangle
    {
        id:baseForm
        color:"#222424"
        anchors.fill: parent
        visible: false;



    Item
        {
            id:baseNewWordFrom
            width:parent.width/2
            height:parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            Column
            {
                anchors.fill: parent
                spacing: 15
                Rectangle { id:rec1; width:100; height:50; color:"transparent";  border.color: "grey";TextInput { id:firstInput; anchors.fill: parent; color:"white"}}
                Rectangle { id:rec2;width:100; height:50; color:"transparent"; border.color: "grey"; TextInput { id:secondInput; anchors.fill: parent; color:"white"}}
                Rectangle { id:rec3;width:100; height:50; color:"transparent";  border.color: "grey";TextInput { id:thirdInput; anchors.fill: parent; color:"white"}}
                Rectangle { id:rec4;width:100; height:50; color:"transparent"; border.color: "grey"; TextInput { id:forthInput; anchors.fill: parent; color:"white"}}
                Rectangle { id:rec5;width:100; height:50; color:"transparent";  border.color: "grey";TextInput { id:fifthInput; anchors.fill: parent; color:"white"}}
                Rectangle { id:rec6;width:100; height:50; color:"transparent"; border.color: "grey"; TextInput { id:sixthInput; anchors.fill: parent; color:"white"}}
                Button
                {
                    text:"save"
                    onClicked:
                    {
                        var data
                        if(formType=="word")
                        {
                            //text, meaning, example, translate, source, status
                            data = [
                                            firstInput.text,
                                            secondInput.text,
                                            thirdInput.text,
                                            forthInput.text,
                                            fifthInput.text,
                                            sixthInput.text
                                        ];

                            backend.addWordToTable(data);
                        }
                        else if(formType=="verb")
                        {
                            //verb, past, past perfect, status
                            data = [
                                            firstInput.text,
                                            secondInput.text,
                                            thirdInput.text,
                                            forthInput.text
                                        ];

                            backend.addWordToTable(data);
                        }
                        else if(formType=="single")
                        {
                            //data order passed by QML for single: text, translate,status
                            data = [
                                            firstInput.text,
                                            secondInput.text,
                                            thirdInput.text,
                                        ];
                            backend.addWordToTable(data);
                        }
                        else
                        {
                            console.log("formtype undefined.. formType=",formType);
                        }


                    }
                }

            }




        }

    }
    Connections
    {
        target: backend
        function onTableTypeIs(currentTableType)
        {
            formType=currentTableType
        }
        function onAddItemtoTableResult(res)
        {
            // console.log("result submit/add item to the table: "+res)
            if (res !== "error")
            {
                firstInput.clear()
                secondInput.clear()
                thirdInput.clear()
                forthInput.clear()
                fifthInput.clear()
                sixthInput.clear()
                // mainStackView.pop();
                // mainStackView.pop();
            }


        }

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
                                                t_type: row.t_type,
                                                text: row.t_title,
                                                value: row.t_status
                                            });
            }
        }
    }
    Component.onCompleted:
    {
        // console.log("add new word page component loaded")
        backend.whatIsCurrentTableType();

        //first time fetch data from backend
        backend.getTables("","all")
    }

}

