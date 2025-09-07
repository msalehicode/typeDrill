import QtQuick
import QtQuick.Controls

Page
{
    id:addNewWordForm
    width:parent.width
    height: parent.height


    property string formType: "none"

    //data order passed by QML to backend
    //word: text, meaning, example, translate, source, status
    //verb: verb, past, past perfect, translate, status
    property var wordTitles: ["Enter Word:", "Enter Meaning:", "Enter Example:", "Enter Translate:", "Enter Source:", "Enter Status:"]
    property var verbTitles: ["Enter Verb:","Enter Past:", "Enter Past Participle:", "Enter Translate:","Enter Status:"]


    ListModel
    {
        id: titleModel
    }



    onFormTypeChanged:
    {
        refreshFormInputs()
    }

    Rectangle
    {
        color:appColors.c_background
        anchors.fill: parent

        Rectangle
        {
            id:baseSelectTable
            color:"transparent"
            anchors.fill: parent
            visible: true

            CustomCombobox
            {
                id: tablesComboBox
                setBgColor: appColors.c_comboboxBgColor
                setFontColor: appColors.c_buttonFontColor
                setBgColorCurrentItem: appColors.c_comboboxBgColorCurrentItem
                anchors.centerIn: parent
                onActivated: function(index)
                {
                    currentIndex = index
                }
            }

            CustomButton
            {
                setButtonText:"select";
                setButtonBorderColor:appColors.c_buttonBorderColor
                setButtonBackColor: appColors.c_buttonBgColor
                setButtonFontColor: appColors.c_buttonFontColor
                setBold: true
                setButtonFontsize: appFontSizes.f_buttonFontSize
                setButtonsBorderWidth: 0
                setRadius: 20
                setWidth: 100
                setHeight: 50
                anchors.top: tablesComboBox.bottom
                anchors.topMargin: 15
                anchors.horizontalCenter: parent.horizontalCenter
                onButtonClicked:
                {
                    if(tablesComboBox.currentIndex>=0)
                    {
                        //because we need payload or that table type (t_type)
                        //don't call tablesComboBox.currentItemText
                        var selectedItem = tablesComboBox.modelData[tablesComboBox.currentIndex]
                        backend.switchTable(selectedItem.text,selectedItem.t_type);
                        backend.whatIsCurrentTableType();
                        baseForm.visible=true
                        baseSelectTable.visible=false
                    }
                }
            }
        }


        Rectangle
        {
            id:baseForm
            visible: false
            color:"transparent"
            width:parent.width/2
            height:parent.height/2
            anchors.centerIn: parent
            Column
            {
                width: parent.width
                height: parent.height
                spacing:25

                Repeater
                {
                    id: repeater
                    model: titleModel
                    delegate: CustomTextInput
                    {
                        setWidth: parent.width
                        setHeight: 50
                        setBgColor: appColors.c_bgColor_textinput
                        setBordercolor: appColors.c_borderColor_textinput
                        setBorderWidth:2
                        setFocus: index === 0
                        setFontSize:appFontSizes.f_textInput
                        setFontColor: appColors.c_fontColor_textinput
                        setRadius:10
                        theText:""
                        setTitleText: model.title
                    }
                }

                CustomButton
                {
                    setButtonText:"add";
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setBold: true
                    setButtonFontsize: appFontSizes.f_buttonFontSize
                    setButtonsBorderWidth: 0
                    setRadius: 20
                    setWidth: 100
                    setHeight: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    onButtonClicked:
                    {
                        var data = [];
                        for (var i = 0; i < repeater.count; i++)
                        {
                            var item = repeater.itemAt(i);
                            // console.log("Input " + i + ": " + item.theText);
                            if (item)
                                data.push(item.theText);
                        }


                        //check empty items
                        if(data[0]==="" || data[0]===" ")
                            console.log("you must fill first item atleast")
                        else
                            backend.addWordToTable(data);
                    }
                }

            }
        }


    }

    function refreshFormInputs()
    {
        titleModel.clear()
        var arr = []
        if (formType === "word")
            arr = wordTitles
        else if (formType === "verb")
            arr = verbTitles
        else
            console.log("formType unkown, formType=",formType)


        for (var i = 0; i < arr.length; i++)
        {
            titleModel.append({"title": arr[i]})
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
            if (res !== "error")
            {
                //reset form for next word
                refreshFormInputs()
                console.log("word added into the table. res="+res)
                //go to homePage
                // mainStackView.pop();
                // mainStackView.pop();
            }
            else
                console.log("error: cant add word to table.. res=" + res)
        }

        function onTablesList(tables)
        {
            // console.log("Received tables list with", tables.length, "rows");
            var data = []
            for (var i = 0; i < tables.length; ++i)
            {
                var row = tables[i];
                // console.log("Row", i, "t_id:", row.t_id, "t_title:", row.t_title, "t_status:", row.t_status);
                data.push({
                                                t_id: row.t_id,
                                                t_text: row.t_title,
                                                t_type: row.t_type,
                                                text: row.t_title,
                                                value: row.t_status
                                            });
            }
            tablesComboBox.modelData=data;
        }
    }
    Component.onCompleted:
    {
        //first time fetch data from backend
        backend.getTables("","all")//empty string is for filter/search between tables, we dont want filter
    }

}

