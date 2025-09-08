import QtQuick
import QtQuick.Controls
import "../CustomComponents"


Page
{
    id:addNewDatabaseFrom
    anchors.fill: parent
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
                    id:databaseName
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
                    setTitleText:"Database Name:"
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
                        //replcae spaces with _ then validation sql databaseName
                        var tableValidName = replaceSpaces(databaseName.theText , "_")
                        if(isValidSQLitedatabaseName(tableValidName))
                        {
                            backend.createDatabase(tableValidName)
                        }
                        else
                        {
                            databaseName.invalidInput("invalid charecters");
                            console.log("invalid charecters for database name")
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

    function isValidSQLitedatabaseName(name)
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

        // Passed all checks
        return true;
    }

    Connections
    {
        target: backend
        function onDatabaseCreationResult(result)
        {
            console.log("database creation result=", result)
            if (result==="1")
            {
                mainStackView.pop();
            }
            else
            {
                console.log("error while creating database...")
            }
        }
    }
}

