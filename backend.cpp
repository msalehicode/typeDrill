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

bool Backend::init(QString databaseName)
{
    if(databaseName.length()<=0)
        databaseName = settings.getValue("currentDatabase").toString();

    settings.initSettings();

    min_id=0;
    m_api_key = settings.getValue("api_key").toString();
    m_api_url = settings.getValue("api_url").toString();

    //set them into variables

    databaseFullPath = QDir(m_dbPath).filePath(databaseName);

    if(m_db.init(m_dbPath, databaseName))
    {
        m_query = new QSqlQuery(m_db.getDatabase());
    }
    else
    {
        // qFatal("failed to init database..");
        return false;
    }


    //create index (list of table/decks)
    m_db.createTable("user_tables", "t_id INTEGER PRIMARY KEY AUTOINCREMENT,\
                     t_title TEXT,\
                     t_type TEXT,\
                     t_icon TEXT,\
                     t_status TEXT"
                     );

    //create practices result table (to trace practice progress)
    m_db.createTable("trace_practices", "tp_id INTEGER PRIMARY KEY AUTOINCREMENT,\
                     tp_table_id INTEGER,\
                     tp_timeSpent TEXT,\
                     tp_mistakesCount TEXT,\
                     tp_date TEXT DEFAULT CURRENT_TIMESTAMP,\
                     FOREIGN KEY(tp_table_id) REFERENCES user_tables(t_id)"
                     );

    qInfo() << "init finish.";
    return true;
}

Backend::Backend(QObject *parent)
    : QObject{parent}
{
    m_dbPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    init();
    connect(&m_fileManager, &FileManager::downloadProgress, this, &Backend::onDownloadProgress);
    connect(&m_fileManager, &FileManager::downloadFinished, this, &Backend::onDownloadFinished);
    connect(&m_fileManager, &FileManager::uploadFinished, this, &Backend::onUploadFinished);
    qInfo() << "constructor finish.";

}

int Backend::getNextWord(const QString &userText)
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
        return max_id;
    }
    else //incorrect value entered.
    {
        QString correctStatus = "incorrect";
        emit wordIsIncorrect(correctStatus);
    }
    return -1;
}

void Backend::setPracticeResult(const QString &mistakeCount, const QString &timeSpent)
{
    QDateTime currentDate = QDateTime::currentDateTime();

    QMap<QString, QVariant> rowData;
    rowData["tp_table_id"] = m_db.searchTable("user_tables","t_title",currentTableName,"t_id");;
    rowData["tp_timeSpent"] = timeSpent;
    rowData["tp_mistakesCount"] = mistakeCount;
    rowData["tp_date"] = currentDate.toString("yyyy-MM-dd HH:mm:ss");


    // for (auto it = rowData.constBegin(); it != rowData.constEnd(); ++it) {
    //     qInfo() << it.key() << ":" << it.value().toString();
    // }
    if(!m_db.insertIntoTable("trace_practices", rowData))
        qWarning() << "failed to insert into table (trace_practice)";
}

void Backend::getTables(const QString& searchedTitle,const QString& tableType)
{
    // Fetch all rows from the "user_tables" table
    QVariantList allTables = m_db.getAllRowsAsVariantList("user_tables");


    //list pinned tables
    QVariantList pinnedTables;
    for (const QVariant &rowVar : allTables)
    {
        QVariantMap row = rowVar.toMap();

        //only append pinned ones
        if(row["t_status"].toString() != "pinned")
            continue;

        // If tableType is "all" or empty, include everything
        if (tableType.isEmpty() || tableType == "all")
            pinnedTables.append(row);
        // Otherwise, filter by t_type (verb,word,single)
        else if (row["t_type"].toString() == tableType)
            pinnedTables.append(row);
    }


    // Filter based on tableType (e.g., "verb", "noun", etc.)
    QVariantList filteredTables;
    for (const QVariant &rowVar : allTables)
    {
        QVariantMap row = rowVar.toMap();

        // don't include pinned tables to avoid duplicate
        if(row["t_status"].toString() == "pinned")
            continue;

        // If tableType is "all" or empty, include everything
        if (tableType.isEmpty() || tableType == "all")
        {
            if(searchedTitle.isEmpty()) //searchedTitle didn't provide
                filteredTables.append(row);
            else if(!searchedTitle.isEmpty() && searchedTitle==row["t_title"].toString())
                filteredTables.append(row);
        }

        // Otherwise, filter by t_type (verb,word,single)
        else if (row["t_type"].toString() == tableType)
        {
            if(searchedTitle.isEmpty()) //searchedTitle didn't provide
                filteredTables.append(row);
            else if(!searchedTitle.isEmpty() && searchedTitle==row["t_title"].toString())
                filteredTables.append(row);
        }
    }


    // merge filteredTables items to pinnedTables (pinnedTables will show first items on UI)
    for (const QVariant &item : filteredTables)
    {
        pinnedTables.append(item);
    }

    emit tablesList(pinnedTables);
}

QString Backend::pinTable(const QString &tableId)
{
    QString tablePinnedStatus = m_db.searchTable("user_tables","t_id",tableId,"t_status");
    QString value="";
    if(tablePinnedStatus=="pinned")
        value="0";
    else
        value="pinned";


    bool qResult = m_db.updateTableValue("user_tables","t_id",tableId,"t_status",value);
    if(qResult)
        return "table status has been updated.";
    return "error couldn't update pin status of table.";
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

void Backend::createDatabase(const QString &databaseName)
{
    bool res = init(databaseName);
    emit databaseCreationResult(QString::number(res));
}

void Backend::whatIsCurrentTableType()
{
    emit tableTypeIs(currentTableType);
}

void Backend::addWordToTable(const QStringList &data)
{
    qInfo() << "addWordToTable received data = " << data;
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
    QDir dir(m_dbPath);

    // Filter for files ending with ".sqlite"
    QStringList filters;
    filters << "*";

    QStringList fileList = dir.entryList(filters, QDir::Files | QDir::NoSymLinks);
    // Remove ".sqlite" extension from each filename
    for (QString &fileName : fileList) {
        if (fileName.endsWith(".sqlite", Qt::CaseInsensitive)) {
            fileName.chop(7);  // Removes last 7 characters (".sqlite")
        }
    }
    return fileList;
}

QString Backend::switchDatabase(const QString &databaseName)
{
    settings.setValue("currentDatabase",databaseName);
    if(init())
    {
        return "successed";
    }
    else
    {
        return "failed";
    }
}

QString Backend::whatIsCurrentDatabase()
{
    return settings.getValue("currentDatabase").toString();
}

QString Backend::getApiUrl()
{
    return m_api_url;
}

QString Backend::getApiKey()
{
    return m_api_key;
}

void Backend::setApiUrl(const QString &apiURL)
{
    m_api_url = apiURL;
    settings.setValue("api_url",m_api_url);
}

void Backend::setApiKey(const QString &apiKey)
{
    m_api_key = apiKey;
    settings.setValue("api_key",m_api_key);
}

void Backend::fetchUrlList()
{
    QUrl url(m_api_url);
    QNetworkRequest request(url);

    request.setRawHeader("X-API-KEY", m_api_key.toUtf8());

    QNetworkReply *reply = m_networkManager.get(request);

    connect(reply, &QNetworkReply::finished, this, &Backend::onUrlListReceived);
}

void Backend::download(const QString &url, const QString &fileName)
{
    m_fileManager.downloadFile(url, fileName);
}

void Backend::uploadFileToApi(const QString &fileName, const QString& publicStatus)
{
    QString filePath = m_dbPath +"/"+ fileName;
    m_fileManager.uploadFile(m_api_url, filePath, m_api_key, publicStatus);
}

QString Backend::getThemeMode()
{
    return settings.getValue("theme").toString();
}

void Backend::setThemeMode(const QString &themeTitle)
{
    if(themeTitle=="light" || themeTitle=="dark")
        settings.setValue("theme",themeTitle);
    else
        qInfo() << "invalid theme title.";
}

QStringList Backend::getStreakDays()
{
    //first item ==> streak days number e.g [26, ...]
    //week days are on or off [26, 0,1,1,...]
    //next days will be question mark [26, 1,0,1,?,?]
    QStringList streak;
    if (m_db.isOpen()) //because its on launch application, need to check db has loaded
    {

        QDate theDate = QDate::currentDate();
        int streakCounter = calculateStreakDays(theDate);
        if(streakCounter==0)
        {
            theDate = theDate.addDays(-1);
            streakCounter = calculateStreakDays(theDate);
        }

        streak << QString::number(streakCounter);


        QDate today = QDate::currentDate();
        int daysFromMonday = today.dayOfWeek() - 1;
        QDate monday = today.addDays(-daysFromMonday);
        QDate yesterday = QDate::currentDate().addDays(-1);

        for (int i = 0; i < 7; ++i) {
            QDate currentDay = monday.addDays(i);
            QString startOfDay = currentDay.toString("yyyy-MM-dd") + " 00:00:00";
            QString endOfDay = currentDay.toString("yyyy-MM-dd") + " 23:59:59";

            QVariantMap params;
            params["start"] = startOfDay;
            params["end"] = endOfDay;

            QVariant result = m_db.runQuery("SELECT COUNT(*) FROM trace_practices WHERE tp_date BETWEEN :start AND :end",
                                            params);

            if (result.isValid()) {
                int count = result.toInt();
                streak.append(count > 0 ? "1" : (currentDay<today) ? "0" : "?");
            } else {
                streak.append("?");
            }
        }

        qInfo() << "streak days result = " << streak;

    } else
    {
        // wait or retry after some time
        qInfo () << "database is not ready for this daystreak query...";
    }

    return streak;

}

int Backend::calculateStreakDays(QDate& currentDate)
{
    int streakCount = 0;
    // QDate currentDate = QDate::currentDate();

    // We'll check days going backwards starting from today
    while (true) {
        QString startOfDay = currentDate.toString("yyyy-MM-dd") + " 00:00:00";
        QString endOfDay = currentDate.toString("yyyy-MM-dd") + " 23:59:59";

        QVariantMap params;
        params["start"] = startOfDay;
        params["end"] = endOfDay;

        QVariant result = m_db.runQuery(
            "SELECT COUNT(*) FROM trace_practices WHERE tp_date BETWEEN :start AND :end",
            params
            );

        if (!result.isValid()) {
            // In case of error, stop counting streak
            qInfo() << "In case of error, stop counting streak";
            break;
        }

        int count = result.toInt();
        if (count > 0)
        {
            // Practiced this day, increment streak and check previous day
            streakCount++;
            currentDate = currentDate.addDays(-1);
        } else {
            // No practice on this day, streak broken
            qInfo() << "No practice on this day, streak broken";
            break;
        }
    }

    qInfo() << "Consecutive practice streak: " << streakCount;
    return streakCount;
}

QDate Backend::getLastActivityDate()
{
    QVariant result = m_db.runQuery("SELECT MAX(tp_date) FROM trace_practices", {});

    if (!result.isValid() || result.isNull()) {
        qInfo() << "No activity records found in database.";
        return QDate();  // Invalid date if no data
    }

    QString dateStr = result.toString();

    // Assuming tp_date is stored as a datetime string like "yyyy-MM-dd HH:mm:ss"
    QDate lastDate = QDate::fromString(dateStr.left(10), "yyyy-MM-dd");

    if (!lastDate.isValid()) {
        qWarning() << "Failed to parse last activity date from database:" << dateStr;
        return QDate();
    }

    qInfo() << "Last activity date from DB:" << lastDate.toString("yyyy-MM-dd");
    return lastDate;
}

int Backend::getLastWindowSize(const QString &widthOrHeight)
{
    if(widthOrHeight=="w" || widthOrHeight=="width")
    {
        return settings.getValue("last_window_width").toInt();
    }
    else
    {
        return settings.getValue("last_window_height").toInt();
    }
}

void Backend::setLastWindowSize(const QString& wOrh , const int &value)
{
    if(wOrh=="w" || wOrh=="width")
    {
        settings.setValue("last_window_width",value);
    }
    else
    {
         settings.setValue("last_window_height",value);
    }
}


void Backend::onUrlListReceived() {
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply)
        return;

    if (reply->error() == QNetworkReply::NoError) {
        QVariantList urlList;
        QByteArray data = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);
        if (doc.isArray()) {
            QJsonArray arr = doc.array();
            for (const auto &item : arr) {
                if (item.isObject()) {
                    QJsonObject obj = item.toObject();
                    QVariantMap map;
                    map["d_name"] = obj["d_name"].toString();
                    map["d_url"] = obj["d_url"].toString();
                    map["d_icon"] = obj["d_icon"].toString();
                    urlList.append(map);
                }
            }
            reply->deleteLater();
            emit urlListReady(urlList);
            return;
        }
    }

    // On failure
    QString error = reply->errorString();
    reply->deleteLater();
    emit urlListFailed(error);
}


void Backend::onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal)
{
    emit downloadProgress(bytesReceived, bytesTotal);

}

void Backend::onDownloadFinished(bool success, const QString &filePath)
{
    emit downloadFinished(success, filePath);

}

void Backend::onUploadFinished(bool success, const QString &result)
{
    emit uploadDone(result);
}

