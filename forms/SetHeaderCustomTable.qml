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


    Column
    {
        id:baseForm
        width: parent.width
        height:parent.height
        visible: false
        spacing:10
        CustomTextInput
        {
            id:headers_input
            setWidth: parent.width/2
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
            setTitleText:"Headers:"
            onTheTextAccepted:
            {
                savebutton.buttonClicked()
            }
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
                //validate theText and selectedTableId


                //submit to backen
                if(isModifingHeader)
                    backend.setCustomTableHeaders(selectedTableId,headers_input.theText,true);
                else
                    backend.setCustomTableHeaders(selectedTableId,headers_input.theText);
            }
        }

    }

    Connections
    {
        target:backend
        function onSetCustomTableHeadersResult(result)
        {
            if(isModifingHeader)
                console.log("update customtable header reuslt= ", result)
            else
                console.log("set customtable header reuslt= ", result)
        }

        function onGetCustomTableHeadersResult(result)
        {
            if(result.length>1)
            {
                isModifingHeader=true
                headers_input.theText=result
                headerText.text="Modifing Headers Custom Table ("+selectedTableName+")"
            }
            else
                headerText.text="Adding Headers For Custom Table ("+selectedTableName+")"

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
