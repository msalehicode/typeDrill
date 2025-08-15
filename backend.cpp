#include "backend.h"

void Backend::wordIs()
{
    last_word.clear();
    if(currentTableType=="word")
    {
        last_word << m_db.searchTable(currentTableName, "id", QString::number(last_id), "text");
        last_word << m_db.searchTable(currentTableName, "id", QString::number(last_id), "meaning");
        last_word << m_db.searchTable(currentTableName, "id", QString::number(last_id), "example");
    }
    else if(currentTableType=="verb")
    {
        last_word << m_db.searchTable(currentTableName, "id", QString::number(last_id), "verb");
        last_word << m_db.searchTable(currentTableName, "id", QString::number(last_id), "past");
        last_word << m_db.searchTable(currentTableName, "id", QString::number(last_id), "past_perfect");
    }
    else if(currentTableType=="single")
    {
        last_word << m_db.searchTable(currentTableName, "id", QString::number(last_id), "text");
        last_word << m_db.searchTable(currentTableName, "id", QString::number(last_id), "translate");
        last_word << m_db.searchTable(currentTableName, "id", QString::number(last_id), "status");
    }
    else
    {
        //just to fill last word with somethinge
        last_word << "error";//, could not detect current table type.
    }

    // qInfo() <<"wordisresult:"<< last_word;
}

Backend::Backend(QObject *parent)
    : QObject{parent}, min_id(0)
{
    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QString dbFileName = "practiceWords.sqlite";
    databaseFullPath = QDir(dbPath).filePath(dbFileName);

    if(m_db.init(dbPath, dbFileName))
    {
        m_query = new QSqlQuery((*m_db.getDatabase()));
    }
    else
        qFatal("failed to init database..");


    m_db.createTable("user_tables", "t_id INTEGER PRIMARY KEY AUTOINCREMENT,\
                     t_title TEXT,\
                     t_type TEXT,\
                     t_icon TEXT,\
                     t_status TEXT"
                     );






}

void Backend::getNextWord(const QString &userText)
{


    // qInfo() <<"debuggg"<< last_word << "" << last_word[0];
    if (last_word.size() > 0 && userText == last_word[0])
    {
        if(last_id>=max_id)
            last_id=min_id;

        last_id++;

        wordIs();
        // qInfo() << "usertext= " << userText;
        // qInfo() << "last_wrod=" << last_word;
        // qInfo() << "last id =" << last_id << "maxid="<<max_id<< "minud="<<min_id;
        emit wordReady(last_word);
    }
    // else
        // qInfo() << "error"; //incorrect value entered.
}

void Backend::getTables(const QString& tableType)
{
    QVariantList filteredTables;

    // Fetch all rows from the "user_tables" table
    QVariantList allTables = m_db.getAllRowsAsVariantList("user_tables");

    // Filter based on tableType (e.g., "verb", "noun", etc.)
    for (const QVariant &rowVar : allTables)
    {
        QVariantMap row = rowVar.toMap();

        // If tableType is "all" or empty, include everything
        if (tableType.isEmpty() || tableType == "all")
        {
            filteredTables.append(row);
        }
        // Otherwise, filter by t_type
        else if (row["t_type"].toString() == tableType)
        {
            filteredTables.append(row);
        }
    }

    emit tablesList(filteredTables);
}


void Backend::createTable(const QString &tableName, const QString &tableType)
{
    QString result;
    if(tableType=="word")
    {
            bool qresult = m_db.createTable(tableName, "id INTEGER PRIMARY KEY AUTOINCREMENT,\
                             text TEXT,\
                             meaning TEXT,\
                             example TEXT,\
                             translate TEXT,\
                             status TEXT,\
                             source TEXT"
                             );
            if(qresult)
            {
                result="word table successfully created.";

                QMap<QString, QVariant> rowData;
                rowData["t_title"] = tableName;
                rowData["t_type"] = tableType;
                rowData["t_icon"] = "";
                rowData["t_status"] = "0";

                qresult = m_db.insertIntoTable("user_tables", rowData);
                if(qresult)
                    result+= " and added to user_tables.";
                else
                    result= "error";//error: could not add to user_tables this will occure problem.
            }
            else
                result="error"; //: table word failed to create.
    }
    else if(tableType=="verb")
    {
        bool qresult = m_db.createTable(tableName, "id INTEGER PRIMARY KEY AUTOINCREMENT,\
                                        verb TEXT,\
                                        past TEXT,\
                                        past_perfect TEXT,\
                                        status TEXT"
                                        );
        if(qresult)
        {
            result="verb table successfully created.";

            QMap<QString, QVariant> rowData;
            rowData["t_title"] = tableName;
            rowData["t_type"] = tableType;
            rowData["t_icon"] = "";
            rowData["t_status"] = "0";

            qresult = m_db.insertIntoTable("user_tables", rowData);
            if(qresult)
                result+= " and added to user_tables.";
            else
                result= "error";// but could not add to user_tables this will occure problem.
        }
        else
            result="error";//: table verb failed to create.
    }
    else if(tableType=="single")
    {
        bool qresult = m_db.createTable(tableName, "id INTEGER PRIMARY KEY AUTOINCREMENT,\
                                        text TEXT,\
                                        translate TEXT,\
                                        status TEXT"
                                        );
        if(qresult)
        {
            result="single table successfully created.";

            QMap<QString, QVariant> rowData;
            rowData["t_title"] = tableName;
            rowData["t_type"] = tableType;
            rowData["t_icon"] = "";
            rowData["t_status"] = "0";

            qresult = m_db.insertIntoTable("user_tables", rowData);
            if(qresult)
                result+= " and added to user_tables.";
            else
                result= "error";// but could not add to user_tables this will occure problem.
        }
        else
            result="error";//: table single failed to create.
    }
    else
    {
        result="error";//: undefined table type.
    }

    emit tableCreationResult(result);
}

void Backend::switchTable(const QString &tableName, const QString& ttype)
{
    currentTableType=ttype;
    currentTableName=tableName;

    resetPractice();

    max_id=m_db.countRows(currentTableName);

    qInfo() << "table switched name=" << currentTableName << "type=" << currentTableType;
    qInfo() << "maxid=" << max_id << "\tminid=" << min_id;
}

void Backend::whatIsCurrentTableType()
{
    emit tableTypeIs(currentTableType);
}

void Backend::addWordToTable(const QStringList &data)
{
    QString result;
    bool qresult;
    if(currentTableType=="word" && data.size() >=6)
    {
        //data order passed by QML for word: text, meaning, example, translate, source, status
        QMap<QString, QVariant> rowData;
        rowData["text"] = data[0];
        rowData["meaning"] = data[1];
        rowData["example"] = data[2];
        rowData["translate"] = data[3];
        rowData["source"] = data[4];
        rowData["status"] = data[5];

        qresult = m_db.insertIntoTable(currentTableName, rowData);
        if(qresult)
            result= "word added to the table.";
        else
            result= "error";//:failed to add word into the table.
    }
    else if(currentTableType=="verb" && data.size() >=4)
    {
        //data order passed by QML for verb: verb, past, past perfect, status
        QMap<QString, QVariant> rowData;
        rowData["verb"] = data[0];
        rowData["past"] = data[1];
        rowData["past_perfect"] = data[2];
        rowData["status"] = data[3];
        qresult = m_db.insertIntoTable(currentTableName, rowData);
        if(qresult)
            result= "verb added to the table.";
        else
            result= "error";//failed to add verb into the table.
    }
    else if(currentTableType=="single" && data.size() >=3)
    {
        //data order passed by QML for single: text, translate,status
        QMap<QString, QVariant> rowData;
        rowData["text"] = data[0];
        rowData["translate"] = data[1];
        rowData["status"] = data[2];
        qresult = m_db.insertIntoTable(currentTableName, rowData);
        if(qresult)
            result= "single added to the table.";
        else
            result= "error";//failed to add single into the table.
    }
    else
    {
        // qInfo() << "undefined table type or invalid parameters.";
        result="error";//, underined table type or invalid parameters
    }

    emit addItemtoTableResult(result);
}

void Backend::resetPractice()
{
    last_id=min_id;
    last_word.clear();
    //to avoid empty QStringList.
    last_word << "";
    // qInfo() << "practice reseted.";
}

QString Backend::databasePath()
{
    return databaseFullPath;
}

QStringList Backend::listOfDatabases()
{
    QString dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir dir(dbPath);

    // Filter for files ending with ".sqlite"
    QStringList filters;
    filters << "*.sqlite";

    QStringList fileList = dir.entryList(filters, QDir::Files | QDir::NoSymLinks);
    // Remove ".sqlite" extension from each filename
    for (QString &fileName : fileList) {
        if (fileName.endsWith(".sqlite", Qt::CaseInsensitive)) {
            fileName.chop(7);  // Removes last 7 characters (".sqlite")
        }
    }
    return fileList;
}

