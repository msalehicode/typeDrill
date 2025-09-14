import QtQuick
import QtQuick.Controls
import "../CustomComponents"

Page
{
    id:addNewWordForm
    width:parent.width
    height: parent.height


    property var parentName: someObject

    //data order passed by QML to backend
    //word: text, meaning, example, translate, source, status
    //verb: verb, past, past perfect, translate ,status
    property var wordTitles: ["text", "meaning", "example", "translate", "status", "source"]
    property var verbTitles: ["verb","past", "past_perfect", "translate","status"]


    //fill from outside
    property string formType: "none"
    property int wordId: -1
    property var formData : ["data1","data2","data3","data4","data5","data6"]

    ListModel
    {
        id: titleModel
    }

    Rectangle
    {
        color:appColors.c_background
        anchors.fill: parent

        Rectangle
        {
            id:baseForm
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

                        theText: model.text
                        setTitleText: model.title
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
                    anchors.horizontalCenter: parent.horizontalCenter
                    onButtonClicked:
                    {
                        if(wordId==-1 || formType==="none")
                            console.log("invalid wordId/formType to modify word.")
                        else
                        {
                            var data = readDataFromRepeater(false,true)
                            //check empty items
                            // if(data[1]==="" || data[1]===" ")
                                // console.log("you must fill first item atleast")
                            // else
                                backend.modifyWordOnTable(wordId, formType, data);
                        }
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


        for(var x=0; x< formData.length; x++)
            console.log("formdata[i]=",formData[x])



        //inject/append form titles, form data into repeater's list
        for (var i = 0; i < arr.length; i++)
        {
            titleModel.append({"title": arr[i],
                               "text": formData[i] || ""
                              })
        }
    }

    function readDataFromRepeater(wihtId=false,dataForBackend=false)
    {
        //read data from reapeater's items
        var data = [];

        //first item of formData is wordId need to fill before modfied data
        if(wihtId && !dataForBackend)
        {
            var obj2 = {};
            obj2["id"] = wordId;
            data.push(obj2);
        }


        for (var i = 0; i < repeater.count; i++)
        {
            var item = repeater.itemAt(i);
            if (item)
            {
                // console.log("Input " + i + ": " + item.setTitleText + " = " + item.theText);
                if(dataForBackend)
                    data.push(item.theText);
                else
                {
                    var obj = {};
                    obj[item.setTitleText] = item.theText;
                    data.push(obj);
                }
            }
            else
                console.log("invalid item repeater to read.")
        }
        return data
    }


    function getValueByKey(dataList, firstKey, secondKey) {
        if (!dataList || dataList.length === 0)
            return "";

        // Check if dataList is an array of objects
        if (Array.isArray(dataList)) {
            var mergedData = {};
            for (var i = 0; i < dataList.length; i++) {
                var item = dataList[i];
                for (var key in item) {
                    mergedData[key] = item[key];  // Merge all objects into one
                }
            }
            // Now mergedData is a single object with all keys
            if (firstKey in mergedData)
                return mergedData[firstKey];
            else if (secondKey in mergedData)
                return mergedData[secondKey];
        }
        else {
            // Assuming dataList is a single object
            var row = dataList[0]; // First object in the list
            if (firstKey in row)
                return row[firstKey];
            else if (secondKey in row)
                return row[secondKey];
        }

        return "";
    }



    function updateTextValues()
    {
        var tempData = []
        tempData.push(getValueByKey(formData,"text","verb")) //pass possible keys to get value
        tempData.push(getValueByKey(formData,"meaning","past")) //pass possible keys to get value
        tempData.push(getValueByKey(formData,"example","past_perfect")) //pass possible keys to get value
        tempData.push(getValueByKey(formData,"translate","translate")) //pass possible keys to get value
        tempData.push(getValueByKey(formData,"source","source")) //pass possible keys to get value
        tempData.push(getValueByKey(formData,"status","status")) //pass possible keys to get value

        formData=tempData
    }


    Connections
    {
        target: backend
        function onModifyWordOnTableResult(res)
        {
            console.log("onModifyWordOnTableResult=",res)
            if(res!=="error")
            {
                parentName.routeBackFromModifyPage(readDataFromRepeater(true,false))
            }
        }
    }
    Component.onCompleted:
    {
        // console.log("received data: wrodId:", wordId, "formtype:",formType, "formData:")
        // console.log("modifyWord received, formData=")
        // for (var i = 0; i < formData.length; ++i)
        // {
        //     var row = formData[i]
        //     for (var key in row)
        //     {
        //         console.log("formData:  " + key + ": " + row[key])
        //     }
        //     console.log("---")
        // }

        //fill form
        updateTextValues()
        refreshFormInputs()
    }

}

