import QtQuick
import QtQuick.Controls
import "../CustomComponents"

Page
{
    property int selectedTableId:-1;
    property bool isModifingHeader:false
    property string selectedTableName:""

    header: Rectangle
    {
        width: parent.width
        height: 60
        color: appColors.c_headerBg
        Label
        {
            id:headerText
            text:"Select Custom Table"
            horizontalAlignment: Text.AlignHCenter
            color: appColors.c_fontcolor
            font.pixelSize: appFontSizes.f_normal
            font.bold:true
            anchors
            {
                verticalCenter:parent.verticalCenter
                left:parent.left
                leftMargin: 50
            }
        }
    }

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
            setIconArrow: appIcons.icon_back_white
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

                    selectedTableId=selectedItem.t_id
                    selectedTableName=selectedItem.text

                    baseForm.visible=true
                    baseSelectTable.visible=false
                    backend.getCustomTableHeaders(selectedTableId);
                }
            }
        }
    }


    ListModel
    {
        id: titleModel
    }

    Column
    {
        id:baseForm
        width: parent.width
        height:parent.height
        visible: false
        spacing:10
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

        CustomTextInput
        {
            id:translateInput
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
            setTitleText: "Translate"
        }
        CustomTextInput
        {
            id:statusInput
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
            setTitleText: "Status"
        }
        CustomButton
        {
            id:savebutton
            setButtonText:"save";
            setButtonBorderColor:appColors.c_buttonBorderColor
            setButtonBackColor: appColors.c_buttonBgColor
            setButtonFontColor: appColors.c_buttonFontColor
            setBold: true
            setButtonFontsize: appFontSizes.f_buttonFontSize
            setButtonsBorderWidth: 0
            setRadius: 20
            setWidth: 100
            setHeight: 50
            onButtonClicked:
            {
                var data = [];
                for (var i = 0; i < repeater.count; i++)
                {
                    var item = repeater.itemAt(i);
                    console.log("Input " + i + ": " + item.theText);
                    if (item)
                        data.push(item.theText);
                }

                data.push(translateInput.theText);
                data.push(statusInput.theText);

                backend.addItemToCustomTable(selectedTableName,data);
            }
        }

    }

    Connections
    {
        target:backend
        function onAddItemToCustomTableResult(result)
        {
            console.log("add content result=",result)
        }

        function onGetCustomTableHeadersResult(result)
        {
            titleModel.clear()
            var titles = []

            headerText.text="Adding Content to Custom Table ("+selectedTableName+")"


            if(result.length>1)
            {
                // Split the string
                titles = result.split(",").map(item => item.trim());

                // Fill missing items up to 10
                while (titles.length < 10)
                {
                    titles.push("Header");
                }
            }
            else
            {
                titles=["Header1","Header2","Header3",
                        "Header4","Header5","Header6",
                        "Header7","Header8","Header9","Header10"]
                console.log("no header found")
            }



            for (var i = 0; i < titles.length; i++)
            {
                titleModel.append({"title": titles[i]})
            }

            console.log("get customtable header reuslt= ", result)
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
        backend.getTables("","customTable",false)//empty string is for filter/search between tables, we dont want filter
    }


}
