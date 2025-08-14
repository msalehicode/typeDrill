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
           // firstInput.placeholderText="word text";
           //  secondInput.placeholderText="word meaning";
           //  thirdInput.placeholderText="word example";
           //  forthInput.placeholderText="word translate";
           //  fifthInput.placeholderText="word source";
           //  sixthInput.placeholderText="word status";
        }
        else if(formType=="verb")
        {
            //verb, past, past perfect, status
            // firstInput.placeholderText="verb";
            //  secondInput.placeholderText="past";
            //  thirdInput.placeholderText="past perfect";
            //  forthInput.placeholderText="status";
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
        color:"#222424"
        anchors.fill: parent


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
                            console.log("formtype undefined..");
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
                firstInput.text=""
                secondInput.text=""
                thirdInput.text=""
                // mainStackView.pop();
                // mainStackView.pop();
            }


        }
    }
    Component.onCompleted:
    {
        // console.log("add new word page component loaded")
        backend.whatIsCurrentTableType();
    }

}

