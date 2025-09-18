import QtQuick
import QtQuick.Controls
import "../CustomComponents"


Page
{
    id:addNewTableFrom
    header: Rectangle
    {
        width: parent.width
        height: 60
        color: appColors.c_headerBg
        Label
        {
            id:headerText
            text:"Add New Table"
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
        anchors.fill: parent
        color:appColors.c_background


        Rectangle
        {
            color:"transparent"
            width:parent.width/1.50
            height:parent.height/2
            anchors.centerIn: parent
            Column
            {
                width: parent.width
                height: parent.height
                spacing:15
                CustomTextInput
                {
                    id:tableName
                    setWidth: parent.width
                    setHeight: 50
                    setBgColor: appColors.c_bgColor_textinput
                    setBordercolor: appColors.c_borderColor_textinput
                    setBorderWidth:2
                    setFocus: true
                    setFontSize:appFontSizes.f_textInput
                    setFontColor: appColors.c_fontColor_textinput
                    setRadius:10
                    theText:""
                    setTitleText:"Table Name:"
                }

                CustomCombobox
                {
                    id: comboType
                    modelData:[ { text: "word"}, { text: "verb"}, {text:"learn"} ]
                    setBgColor: appColors.c_comboboxBgColor
                    setFontColor: appColors.c_buttonFontColor
                    setIconArrow: appIcons.icon_back_white
                    setBgColorCurrentItem: appColors.c_comboboxBgColorCurrentItem
                    onActivated: function(index)
                    {
                        currentIndex = index
                    }
                }


                CustomButton
                {
                    setButtonText:"create";
                    setButtonBorderColor:appColors.c_buttonBorderColor
                    setButtonBackColor: appColors.c_buttonBgColor
                    setButtonFontColor: appColors.c_buttonFontColor
                    setBold: true
                    setButtonFontsize: appFontSizes.f_buttonFontSize
                    setButtonsBorderWidth: 0
                    setRadius: 20
                    setWidth: 100
                    setHeight: 50
                    // anchors.verticalCenter:parent.verticalCenter
                    onButtonClicked:
                    {
                        //replcae spaces with _ then validation sql tableName
                        var tableValidName = replaceSpaces(tableName.theText , "_")
                        if(isValidSQLiteTableName(tableValidName))
                        {
                            backend.createTable(tableValidName, comboType.currentItemText)
                        }
                        else
                        {
                            tableName.invalidInput("invalid charecters");
                            console.log("invalid charecters for table name")
                        }
                    }
                }

            }
        }
    }

    function replaceSpaces(str,fillWith)
    {
        return str.replace(/ /g, fillWith);
    }

    function isValidSQLiteTableName(name)
    {
        // List of some common SQLite reserved keywords (case-insensitive)
        const reservedKeywords = new Set([
                                             "ABORT", "ACTION", "ADD", "AFTER", "ALL", "ALTER", "ANALYZE", "AND", "AS",
                                             "ASC", "ATTACH", "AUTOINCREMENT", "BEFORE", "BEGIN", "BETWEEN", "BY",
                                             "CASCADE", "CASE", "CAST", "CHECK", "COLLATE", "COLUMN", "COMMIT",
                                             "CONFLICT", "CONSTRAINT", "CREATE", "CROSS", "CURRENT_DATE",
                                             "CURRENT_TIME", "CURRENT_TIMESTAMP", "DATABASE", "DEFAULT", "DEFERRABLE",
                                             "DEFERRED", "DELETE", "DESC", "DETACH", "DISTINCT", "DROP", "EACH",
                                             "ELSE", "END", "ESCAPE", "EXCEPT", "EXCLUSIVE", "EXISTS", "EXPLAIN",
                                             "FAIL", "FOR", "FOREIGN", "FROM", "FULL", "GLOB", "GROUP", "HAVING",
                                             "IF", "IGNORE", "IMMEDIATE", "IN", "INDEX", "INDEXED", "INITIALLY",
                                             "INNER", "INSERT", "INSTEAD", "INTERSECT", "INTO", "IS", "ISNULL", "JOIN",
                                             "KEY", "LEFT", "LIKE", "LIMIT", "MATCH", "NATURAL", "NO", "NOT", "NOTNULL",
                                             "NULL", "OF", "OFFSET", "ON", "OR", "ORDER", "OUTER", "PLAN", "PRAGMA",
                                             "PRIMARY", "QUERY", "RAISE", "RECURSIVE", "REFERENCES", "REGEXP",
                                             "REINDEX", "RELEASE", "RENAME", "REPLACE", "RESTRICT", "RIGHT", "ROLLBACK",
                                             "ROW", "SAVEPOINT", "SELECT", "SET", "TABLE", "TEMP", "TEMPORARY",
                                             "THEN", "TO", "TRANSACTION", "TRIGGER", "UNION", "UNIQUE", "UPDATE",
                                             "USING", "VACUUM", "VALUES", "VIEW", "VIRTUAL", "WHEN", "WHERE", "WITH",
                                             "WITHOUT"
                                         ]);

        if (typeof name !== "string") return false;

        // Check if empty
        if (name.length === 0) return false;

        // Check start: must be letter (a-z, A-Z) or underscore (_)
        if (!/^[A-Za-z_]/.test(name)) return false;

        // Check all characters: only letters, digits, underscores
        if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(name)) return false;

        // Check reserved keyword (case-insensitive)
        if (reservedKeywords.has(name.toUpperCase())) return false;

        if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(name)) return false;

        if(name === "user_tables") return false;
        // Passed all checks
        return true;
    }

    Connections
    {
        target: backend
        function onTableCreationResult(result)
        {
            console.log("table creation result=", result)
            if (result !== "error")
            {
                mainStackView.pop();
            }
            else
            {
                console.log("error while creating table...")
            }
        }
    }
}

