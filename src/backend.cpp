#include "../include/backend.h"

bool Backend::init(QString databaseName)
{
    settings.initSettings();


// #ifdef Q_OS_ANDROID
    // hideAndroidNavigation();
// #endif

    //for switching between databases
    if(databaseName.length()<=0)
        databaseName = settings.getValue("currentDatabase").toString();
    else //update qsettings
        settings.setValue("currentDatabase",databaseName);

    min_id=0;
    m_session_key = settings.getValue("session_key").toString();
    m_api_url = settings.getValue("api_url").toString();

    databaseFullPath = QDir(m_dbPath).filePath(databaseName);
    localFileManager.setPath(m_dbPath);

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


    //custom table headers
    m_db.createTable("user_ct_headers", "ct_id INTEGER PRIMARY KEY AUTOINCREMENT,\
                     ct_tid INTEGER,\
                     ct_headers TEXT,\
                     FOREIGN KEY(ct_tid) REFERENCES user_tables(t_id)"
                     );

    //create practices result table (to trace practice progress)
    m_db.createTable("trace_practices", "tp_id INTEGER PRIMARY KEY AUTOINCREMENT,\
                     tp_table_id INTEGER,\
                     tp_timeSpent TEXT,\
                     tp_mistakesCount TEXT,\
                     tp_practiceType INTEGER,\
                     tp_date TEXT DEFAULT CURRENT_TIMESTAMP,\
                     FOREIGN KEY(tp_table_id) REFERENCES user_tables(t_id)"
                     );

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
}

void Backend::getNextWord(const QString &userText, const bool& isModified, const QString& status)
{
    QString correctStatus = "incorrect";

    qInfo() << "getNextWord() starts, " << userText << "ismod:"<< isModified;
    if (!userText.isEmpty() && //check for filled value isn't empty and
          ((
                current_word.isEmpty() //for first time this is empty. to get first word
             || userText == current_word.first().value("text").toString() //check for text
            ) || isModified)
        )
    {
        if(last_id>=max_id)
            emit practiceFinished();
        else
        {
            //increase to get next word, else again get currentIndex for changes
            if(!isModified)
            {
                qInfo()<< "lets get next word...";
                last_id++;
            }
            else
            {
                qInfo() << "lets fetch again that word its modified";
            }

            current_word = m_db.searchTable(currentTableName, "id", QString::number(last_id));

            //check word status (possibles: empty, all, starred, archived, 0)
            //0->not starred, not archived
            //empty/all -> whole words no filter
            if(status!="all")
            {
                if (!current_word.isEmpty())
                {
                    QVariant wordStatus = current_word[0].value("status");
                    qInfo() << "word status=" << wordStatus.toString();
                    while(wordStatus.toString()!=status) //get next word
                    {
                        if(last_id>=max_id)
                        {
                            emit practiceFinished();
                            break;
                        }
                        else
                        {
                            last_id++;
                            current_word = m_db.searchTable(currentTableName, "id", QString::number(last_id));
                            wordStatus = current_word[0].value("status");
                        }
                    }

                }
                else
                    qInfo() << "curretn word is empty! cant check word status";
            }
            else
                qInfo() << "all or empty status";


            if(isModified)
            {
                qInfo () << "lets check again..";
                if(userText == current_word.first().value("text").toString())
                {
                    qInfo() <<" your right, its match.. lets get new word";
                    current_word = m_db.searchTable(currentTableName, "id", QString::number(++last_id));
                    emit wordReady(current_word);
                }
                else
                    emit wordIsIncorrect(correctStatus);
            }
            else
                emit wordReady(current_word);


            // Print results
            // qDebug() << "Search Results:";
            // for (const auto& row : current_word)
            // {
            //     for (auto it = row.constBegin(); it != row.constEnd(); ++it)
            //         qDebug() << it.key() << ":" << it.value();
            //     qDebug() << "ccc------";
            // }
        }

    }
    else //incorrect value entered.
    {
        emit wordIsIncorrect(correctStatus);
    }
}


void Backend::googleTTS(const QString &text,const QString& saveAs)
{
    if(settings.getValue("saveTTSvoice").toString()=="true")
    {
        if(localFileManager.isFileExist(m_contentPath,saveAs+".mp3"))
        {
            qInfo()<< "voice exists, no need to load from googleTTS";
            emit ttsDone(true,saveAs+".mp3");
        }
        else
        {
            qInfo () <<"voice not exists lets get from google tts";
            gtts.downloadTTS(text,m_contentPath,saveAs);
            connect(&gtts, &GoogleTTS::ttsResult, this, &Backend::onTTSResult);
        }
    }
    else
    {
        //no download just play
        //gtts.playTTS(text);
        qInfo() <<"setting save TTS is off!";
    }
}

bool Backend::setWordStatus(const int &wordId, QString status)
{
    bool qResult = m_db.updateTableValue(currentTableName,"id",wordId,"status",status);

    if(!qResult)
        qInfo() << "failed to update word\'s status to " << status;

    return qResult;
}


void Backend::getWordNoInputCheck(const QString& status,const bool& isForward)
{
    if(isForward)
    {
        if(status!="all")
            previousId.push_back(last_id); //save last random id from word

        if (!getNextMatchingWord(status))
        {
            emit practiceFinished();
            return;
        }
    }
    else//backward
    {
        if (last_id <= 1)
        {
            emit practiceFinished();
            return;
        }
        else
        {
            if(status!="all")
            {
                if(!previousId.isEmpty())
                    last_id = previousId.takeLast();
            }
            else
            {
                last_id--;
            }


            if(last_id<=0)
            {
                emit practiceFinished();
                return;
            }
        }

        current_word = m_db.searchTable(currentTableName, "id", QString::number(last_id));
    }

    emit wordReady(current_word);
}

int Backend::getMaxIdWordTable()
{
    return max_id;
}

int Backend::getCountOfWordsStatusTable(const QString &status)
{
    int count = m_db.countRowsWhere(currentTableName,"status",status);
    return count;
}

QVariantList Backend::getTableWords()
{
    return m_db.getAllRowsAsVariantList(currentTableName);
}

void Backend::addLessonToLearn(const QStringList &data)
{
    if(data.size()>=5)
    {
        QMap<QString, QVariant> rowData;

        rowData["title"] = data[0];
        rowData["details"] = data[1];
        rowData["text"] = data[2];
        rowData["level"] = data[3];
        rowData["status"] = data[4];

        bool qresult = m_db.insertIntoTable(currentTableName, rowData);
        if(qresult)
            emit addContentToLearnResult("lesson added");
        else
            emit addContentToLearnResult("lesson failed to add");
    }
    else
        emit addContentToLearnResult("lesson failed to add not enough parameter");


}



QString Backend::getSetting(const QString &settingKey)
{
    return settings.getValue(settingKey).toString();
}

void Backend::setSetting(const QString &settingKey, const QString &settingValue)
{
    settings.setValue(settingKey,settingValue);
    qInfo() << "setting " << settingKey << " set to " << settingValue << " newvalue=" << getSetting(settingKey);
}

QString Backend::getVersion()
{
    //version and build macro from cmake
    QString result;
    result += QString::fromUtf8(APP_VERSION);
    result += "\n";
    result += QString::fromUtf8(BUILD_DATE_TIME);
    return result;
}

void Backend::setPracticeResult(const QString &mistakeCount, const QString &timeSpent, const int& practiceType)
{
    QDateTime currentDate = QDateTime::currentDateTime();

    QMap<QString, QVariant> rowData;
    rowData["tp_table_id"] = m_db.searchTable("user_tables","t_title",currentTableName,"t_id");;
    rowData["tp_timeSpent"] = timeSpent;
    rowData["tp_mistakesCount"] = mistakeCount;
    rowData["tp_practiceType"] = practiceType;
    rowData["tp_date"] = currentDate.toString("yyyy-MM-dd HH:mm:ss");


    // for (auto it = rowData.constBegin(); it != rowData.constEnd(); ++it) {
    //     qInfo() << it.key() << ":" << it.value().toString();
    // }
    if(!m_db.insertIntoTable("trace_practices", rowData))
        qWarning() << "failed to insert into table (trace_practice)";
}

void Backend::getTables(const QString& searchedTitle,const QString& tableType,  bool includePinned)
{
    // Fetch all rows from the "user_tables" table
    QVariantList allTables = m_db.getAllRowsAsVariantList("user_tables");


    //list pinned tables
    QVariantList pinnedTables;
    if(includePinned)
    {
        for (const QVariant &rowVar : allTables)
        {
            QVariantMap row = rowVar.toMap();

            //only append pinned ones
            if(row["t_status"].toString() != "pinned")
                continue;

            // If tableType is "all" or empty, include everything
            if (tableType.isEmpty() || tableType == "all")
                pinnedTables.append(row);
            // Otherwise, filter by t_type (word,etc)
            else if (row["t_type"].toString() == tableType)
                pinnedTables.append(row);
        }
    }



    // Filter based on tableType (e.g., "word", archives, etc.)
    QVariantList filteredTables;
    for (const QVariant &rowVar : allTables)
    {
        QVariantMap row = rowVar.toMap();

        // don't include pinned tables to avoid duplicate
        if(row["t_status"].toString() == "pinned")
            continue;


        //check for if user fileterd/wants only archives
        if(tableType=="archives")
        {
            if(row["t_status"].toString() == "archived")
                filteredTables.append(row);
        }
        else
        {
            //avoid list archived tables
            if(row["t_status"].toString() == "archived")
                continue;

            // If tableType is "all" or empty, include everything
            if ((tableType.isEmpty() || tableType == "all" ) && tableType!="learn")
            {
                if(searchedTitle.isEmpty()) //searchedTitle didn't provide
                    filteredTables.append(row);
                else if(!searchedTitle.isEmpty() && searchedTitle==row["t_title"].toString())
                    filteredTables.append(row);
            }

            // Otherwise, filter by t_type (word,etc)
            else if (row["t_type"].toString() == tableType)
            {
                if(searchedTitle.isEmpty()) //searchedTitle didn't provide
                    filteredTables.append(row);
                else if(!searchedTitle.isEmpty() && searchedTitle==row["t_title"].toString())
                    filteredTables.append(row);
            }
            else
                qInfo()<<"could not proccess table type." << tableType;
        }

    }


    // merge filteredTables items to pinnedTables (pinnedTables will show first items on UI)
    for (const QVariant &item : filteredTables)
    {
        pinnedTables.append(item);
    }

    // qInfo() << "tableList content:";
    //  for (const QVariant& item : pinnedTables)
    // {
    //     qInfo()<<item;
    //  }

    emit tablesList(pinnedTables);
}

void Backend::getLessonsList()
{
    QVariantList allLessons = m_db.getAllRowsAsVariantList(currentTableName);
    qInfo() << "allLessons content:";
    for (const QVariant& item : allLessons)
    {
        qInfo()<<item;
    }
    emit lessonList(allLessons);
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
                             picture TEXT,\
                             audio TEXT,\
                             type TEXT,\
                             source TEXT"
                             );
            if(qresult)
            {
                result="word table successfully created.";

                //create directory for pictures of table
                if(localFileManager.makeDirectory(whatIsCurrentDatabase()+"_"+tableName))
                    qInfo() << "direcrry doesnt exists so made one";
                else
                    qInfo() <<"database exists or couldnt add one";

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
    else if(tableType=="learn")
    {
        bool qresult = m_db.createTable(tableName, "id INTEGER PRIMARY KEY AUTOINCREMENT,\
                                        title TEXT,\
                                        details TEXT,\
                                        text TEXT,\
                                        level INTEGER,\
                                        status TEXT"
                                        );
        if(qresult)
        {
            result="learn table successfully created.";

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
            result="error";//: table learn failed to create.
    }
    else if(tableType=="customTable")
    {
        bool qresult = m_db.createTable(tableName, "id INTEGER PRIMARY KEY AUTOINCREMENT,\
                                        item1 TEXT,\
                                        item2 TEXT,\
                                        item3 TEXT,\
                                        item4 TEXT,\
                                        item5 TEXT,\
                                        item6 TEXT,\
                                        item7 TEXT,\
                                        item8 TEXT,\
                                        item9 TEXT,\
                                        item10 TEXT,\
                                        translate TEXT,\
                                        status TEXT"
                                        );
        if(qresult)
        {
            result="custom table successfully created.";

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
            result="error";//: table customTable failed to create.
    }
    else
    {
        result="error";//: undefined table type.
    }

    emit tableCreationResult(result);
}

void Backend::setCustomTableHeaders(const int& tableId, const QString &headers, bool update)
{
    if(update)
    {
        QMap<QString, QVariant> rowData;

        rowData["ct_tid"] = QString::number(tableId);
        rowData["ct_headers"] = headers;

        bool qresult = m_db.updateTableRow("user_ct_headers", "ct_tid", QString::number(tableId), rowData);

        if(!qresult)
        {
            emit setCustomTableHeadersResult("failed to insert into table (user_ct_headers)");
            qWarning() << "failed to insert into table (user_ct_headers)";
        }
        else
            emit setCustomTableHeadersResult("headers updated fine");
    }
    else
    {
        QMap<QString, QVariant> rowData;

        rowData["ct_tid"] = QString::number(tableId);
        rowData["ct_headers"] = headers;

        if(!m_db.insertIntoTable("user_ct_headers", rowData))
        {
            emit setCustomTableHeadersResult("failed to insert into table (user_ct_headers)");
            qWarning() << "failed to insert into table (user_ct_headers)";
        }
        else
            emit setCustomTableHeadersResult("table headers inserted fine.");
    }
}

void Backend::getCustomTableHeaders(const int &tableId)
{
    emit getCustomTableHeadersResult(m_db.searchTable("user_ct_headers","ct_tid",QString::number(tableId),"ct_headers"));
}

void Backend::addItemToCustomTable(const QString& tableName, const QStringList &data)
{
    if(data.size()>=12)
    {
        QMap<QString, QVariant> rowData;
        rowData["item1"] = data[0];
        rowData["item2"] = data[1];
        rowData["item3"] = data[2];
        rowData["item4"] = data[3];
        rowData["item5"] = data[4];
        rowData["item6"] = data[5];
        rowData["item7"] = data[6];
        rowData["item8"] = data[7];
        rowData["item9"] = data[8];
        rowData["item10"] = data[9];
        rowData["translate"] = data[10];
        rowData["status"] = data[11];

        bool qresult = m_db.insertIntoTable(tableName, rowData);
        if(qresult)
            emit addItemToCustomTableResult("content added to custom table");
        else
            emit addItemToCustomTableResult("failed to add content to custom table");
    }
    else
    {
        emit addItemToCustomTableResult("failed to add content to custom table not enough data received");
    }

}

void Backend::switchTable(const QString &tableName, const QString& ttype)
{
    currentTableType=ttype;
    currentTableName=tableName;

    resetPractice();

    m_contentPath = m_dbPath + "/" +
                        whatIsCurrentDatabase()+"_"
                          +currentTableName+"/";

    //make sure directory content exists for this table
    if(localFileManager.makeDirectory(whatIsCurrentDatabase()+"_"+currentTableName))
        qInfo() << "directory doesnt exists so made one while switching table";


    max_id=m_db.countRows(currentTableName);

    qInfo() << "table switched name=" << currentTableName << "type=" << currentTableType;
    qInfo() << "maxid=" << max_id << "\tminid=" << min_id;
}

void Backend::createDatabase(const QString &databaseName)
{
    bool res = init(databaseName);
    emit databaseCreationResult(QString::number(res));
}

void Backend::removeDatabase(const QString &databaseName)
{
    qInfo() << "removeDatabase.. " << databaseName;
    QString currentdb = settings.getValue("currentDatabase").toString();
    bool allowedToRemove=true;
    if(databaseName==currentdb)
    {
        QStringList dbList = listOfDatabases();

        if(dbList.size()>1)
        {
            QString otherDbName="";
            int randomInt=0;

            do
            {
                randomInt = QRandomGenerator::global()->bounded(dbList.size());
                otherDbName = dbList[randomInt];
            }
            while(otherDbName==currentdb);

            if(switchDatabase(otherDbName)=="successed")
            {
                qDebug () <<"switch database successed.";
            }
            else
            {
               //error switch to db
                qDebug() << "error switch to db";
                allowedToRemove=false;
            }

        }
        else
        {
            //not enough database..
            qDebug() << "not enough database..";
            allowedToRemove=false;
        }
    }

    if(allowedToRemove)
    {
        allowedToRemove = localFileManager.removeFile(databaseName);
        if(allowedToRemove)
        {
            //remove content of tabels on this database
            if(localFileManager.removeDirectoriesWithPrefix(databaseName+"_"))
            {
                qInfo() <<"database contents removed fine";
            }
            else
                qInfo() <<"failed to remove database contents";
        }

    }

    emit databaseRemoveResult(allowedToRemove);
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
        QString ImagefileName = localFileManager.extractFileName(data[6]);
        QString AudioFileName = localFileManager.extractFileName(data[7]);
        QString destination = whatIsCurrentDatabase()+"_"
                              +currentTableName+"/";

        //data order passed by QML for word: text, meaning, example, translate, source, status
        QMap<QString, QVariant> rowData;
        rowData["text"] = data[0];
        rowData["meaning"] = data[1];
        rowData["example"] = data[2];
        rowData["translate"] = data[3];
        rowData["source"] = data[4];
        rowData["status"] = data[5];
        rowData["picture"] = ImagefileName;//6
        rowData["audio"] = AudioFileName;//7
        rowData["type"] = data[8];

        qresult = m_db.insertIntoTable(currentTableName, rowData);
        if(qresult)
        {
            result= "word added to the table ";

            //if directory doesnt exsits make one
            if(localFileManager.makeDirectory(whatIsCurrentDatabase()+"_"+currentTableName))
                qInfo() << "direcrry doesnt exists so we've made one";
            else
                qInfo() <<"directory content exists or couldnt add one";

            //try to copy picture from data[6] to directory of table
            bool re = localFileManager.copyFile(data[6],destination+ImagefileName);
            if(re)
                result+= " & picture copied successfully";
            else
                result+= " & couldn't copy picture";



            //copy audio file
            re = localFileManager.copyFile(data[7],destination+AudioFileName);
            if(re)
                result+= " & audio copied successfully";
            else
                result+= " & couldn't copy audio";

        }
        else
            result= "error";//:failed to add word into the table.
    }
    else
    {
        qInfo() << "undefined table type or invalid parameters to add word";
        result="error";//, underined table type or invalid parameters
    }

    emit addItemtoTableResult(result);
}

void Backend::modifyWordOnTable(const int& targetWordId,
                                const QString& tagetTableType, const QStringList &data)
{
    // qInfo() << "backend modifyWordOnTable received id=" << targetWordId << ",data=" << data;
    QString result;
    bool qresult;
    QMap<QString, QVariant> rowData;

    QString picture = data[6];
    QString oldPicture = data[7];
    QString audio = data[8];
    QString oldAudio = data[9];

    qInfo() << "modify data stringlist=" << data;

    //to fillup path of picture/audio and avoid empty when its removed/no changed
    QString imageFileName ,audioFileName;
    if(picture=="nochange") //save same
        imageFileName = oldPicture;
    else //removed or changed
        imageFileName = localFileManager.extractFileName(picture);


    if(audio=="nochange") //save same
        audioFileName = oldAudio;
    else //removed or changed
        audioFileName = localFileManager.extractFileName(audio);


    if(tagetTableType=="word" && data.size() >=10)
    {
        //data order passed by QML for word: text, meaning, example, translate, source, status
        rowData["text"] = data[0];
        rowData["meaning"] = data[1];
        rowData["example"] = data[2];
        rowData["translate"] = data[3];
        rowData["source"] = data[4];
        rowData["status"] = data[5];
        rowData["picture"] = imageFileName;//[6,7]
        rowData["audio"] = audioFileName;//[8,9]
        rowData["type"] = data[10];

        qresult = m_db.updateTableRow(currentTableName, "id", targetWordId, rowData);
        if(qresult)
        {
            result= "word modified in the table";
            QString destination = whatIsCurrentDatabase()+"_"
                                  +currentTableName+"/";

            //picture is removed
            if(picture=="remove")
            {
                if(localFileManager.removeFile(destination+oldPicture))
                    result+= " , picture removed.";
                else
                    result += " , couldn't remove picture";
            }
            else if(picture=="nochange") //picture didn't change at all
            {
                result+= " , picture didn't change.";
            }
            else //remove old one and copy new one
            {
                if(oldPicture!="")
                {
                    if(localFileManager.removeFile(destination+oldPicture))
                    {
                        result += " , previous picture removed";
                    }
                    else
                    {
                        result += " , couldn't remove previous picture";
                    }
                }


                //if directory doesnt exsits make one
                if(localFileManager.makeDirectory(whatIsCurrentDatabase()+"_"+currentTableName))
                    qInfo() << "direcrry doesnt exists so made one";
                else
                    qInfo() <<"directory content exists or couldnt add one";


                //copy picture
                qresult = localFileManager.copyFile(picture,destination+imageFileName);
                if(qresult)
                    result+= " , picture copied.";
                else
                    result+= " , picture couldn't copy.";
            }


            //audio is removed
            if(audio=="remove")
            {
                if(localFileManager.removeFile(destination+oldAudio))
                    result+= " , audio removed.";
                else
                    result += " , couldn't remove audio";
            }
            else if(audio=="nochange")
            {
                result+= " ,audio didn't change.";
            }
            else //remove old one and copy new one
            {
                if(oldAudio!="")
                {
                    if(localFileManager.removeFile(destination+oldAudio))
                    {
                        result += " , previous audio removed";
                    }
                    else
                    {
                        result += " , couldn't remove previous audio";
                    }
                }


                //if directory doesnt exsits make one
                if(localFileManager.makeDirectory(whatIsCurrentDatabase()+"_"+currentTableName))
                    qInfo() << "direcrry doesnt exists so made one";
                else
                    qInfo() <<"directory content exists or couldnt add one";


                //copy picture
                qresult = localFileManager.copyFile(picture,destination+audioFileName);
                if(qresult)
                    result+= " , audio copied.";
                else
                    result+= " , audio couldn't copy.";
            }
        }
        else
            result= "error";//:failed to modify word on the table.
    }
    else
    {
        qInfo() << "undefined table type or invalid parameters to modify word.";
        result="error";//, underined table type or invalid parameters
    }

    emit modifyWordOnTableResult(result);
}

void Backend::resetPractice()
{
    last_id=min_id;
    current_word.clear();
    previousId.clear();
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

QString Backend::getSessionKey()
{
    return m_session_key;
}

QString Backend::getUsername()
{
    return settings.getValue("username").toString();
}

void Backend::setApiUrl(const QString &apiURL)
{
    m_api_url = apiURL;
    settings.setValue("api_url",m_api_url);
}

void Backend::setSessionKey(const QString &sessionKey)
{
    m_session_key = sessionKey;
    settings.setValue("session_key",m_session_key);
}

void Backend::fetchUrlList(const QString& visibilityFilter)
{
    QUrl url(m_api_url);
    // Append query parameters to the URL
    QUrlQuery query;

    query.addQueryItem("request", "get-db-list");
    query.addQueryItem("sessionKey", m_session_key);
    query.addQueryItem("getOnly", visibilityFilter);

    url.setQuery(query);

    QNetworkRequest request(url);

    // Send the GET request
    QNetworkReply *reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, this, &Backend::onUrlListReceived);
}

void Backend::download(const QString &url, const QString &fileName, bool overwriteFileName)
{
    m_fileManager.downloadFile(url, fileName, overwriteFileName);
}

void Backend::overwriteFileToApi(const QString &fileName)
{
    QString filePath = m_dbPath +"/"+ fileName;
    m_fileManager.uploadFile(m_api_url, filePath, m_session_key, "false", "update-db");
}

void Backend::syncDatabaseWithApi(const QString &fileName)
{

    QString filePath = m_dbPath +"/"+ fileName;
    qInfo() << "sync fileName= " << fileName << "filePath="<<filePath;

    QDateTime lastModifyLocalFile = localFileManager.getLastModified(filePath);
    QString strLastModifyDate = lastModifyLocalFile.toUTC().toString("yyyy-MM-dd HH:mm:ss");
    qInfo() << "strLastModifyDate=" << strLastModifyDate << " lastModifyLocalFile="<<lastModifyLocalFile.toString();

    m_fileManager.uploadFile(m_api_url, filePath, m_session_key, "false","sync-db",strLastModifyDate);
}

void Backend::uploadFileToApi(const QString &fileName, const QString& publicStatus, const QString& uploadType)
{
    QString filePath = m_dbPath +"/"+ fileName;
    m_fileManager.uploadFile(m_api_url, filePath, m_session_key, publicStatus, uploadType);
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


        //calculate streat days and add at index[0]
        QDate theDate = QDate::currentDate();
        int streakCounter = calculateStreakDays(theDate);
        if(streakCounter==0)
        {
            //streak not found, so let's go check previous day
            theDate = theDate.addDays(-1);
            streakCounter = calculateStreakDays(theDate);
        }
        streak << QString::number(streakCounter);




        //calculate acitivy of week for weekreport
        QDate today = QDate::currentDate();
        int daysFromMonday = today.dayOfWeek() - 1;
        QDate monday = today.addDays(-daysFromMonday);

        int res=0;
        for (int i = 0; i < 7; ++i)
        {
            QDate currentDay = monday.addDays(i);
            res = countActivitiesOfDate(currentDay);
            if(res>0)
                streak.append("1");
            else if(currentDay<today)
                streak.append("0");
            else
                streak.append("?");
        }

        qInfo() << "streak days result = " << streak;

    } else
    {
        // wait or retry after some time
        qInfo () << "database is not ready for this daystreak query...";
    }

    return streak;

}


void Backend::getBackupTableContentFromAPI(const QString& tblName)
{
    //setup file database_talbeNAme for request
    QString dbAndTableName;
    if(tblName.isEmpty())
        dbAndTableName= whatIsCurrentDatabase() + "_" + currentTableName;
    else
        dbAndTableName= whatIsCurrentDatabase() + "_" + tblName;
    dbAndTableName+=".qpack";



    //get file name from API
    QUrl url(m_api_url);
    QUrlQuery query;
    query.addQueryItem("request", "getLatestTableContent");
    query.addQueryItem("sessionKey", m_session_key);
    query.addQueryItem("dbAndTableName", dbAndTableName);
    url.setQuery(query);
    QNetworkRequest request(url);
    QNetworkReply *reply = m_networkManager.get(request);
    // connect(reply, &QNetworkReply::finished, this, &Backend::onLatestTableContentFileName);
    connect(reply, &QNetworkReply::finished, this, [this, dbAndTableName]()
    {
        onLatestTableContentFileName(dbAndTableName);
    });


    //on onLatestTableContentFileName if succeed will downlod and decompress file
}

void Backend::saveBackupTableContentToAPI()
{
    //make and compress backup
    QString dirName = whatIsCurrentDatabase() + "_" + currentTableName;
    QString thePath = m_dbPath+"/"+dirName;
    QString output = m_dbPath+"/"+dirName+".qpack";
    bool result = contentArchive.compressDirectory(thePath,output);
    qInfo() << "compress result = " << result << "source path=" << thePath << "output= " << output;


    //upload archive file to api
    uploadFileToApi(dirName+".qpack","false","upload-tableContent"); //assuming contents are private
}

void Backend::unarchiveQpack(const QString &qpackPath)
{
    QString output = m_dbPath+"/"+ localFileManager.getFileBaseName(qpackPath);
    if(contentArchive.decompressToDirectory(qpackPath,output))
        qInfo() << "unarchive qpack succeed (" << qpackPath  << ") to (" << output << ")";
    else
        qInfo() << "unarchive qpack failed (" << qpackPath << ")";
}

void Backend::deleteTableContent()
{
    //temp remove old dire
    QString dirName = whatIsCurrentDatabase() + "_" + currentTableName;
    localFileManager.removeDirectoryAndContains(dirName);
}


QString Backend::getContentPath() const
{
    return m_contentPath;
}

void Backend::changeApiDbFileVisiblity(const QString &fileId, const QString &newStatus)
{
    QUrl url(m_api_url);
    // Append query parameters to the URL
    QUrlQuery query;

    query.addQueryItem("request", "update-visibility");
    query.addQueryItem("sessionKey", m_session_key);
    query.addQueryItem("fileId", fileId);
    query.addQueryItem("visibility", newStatus);

    url.setQuery(query);

    QNetworkRequest request(url);

    // Send the GET request
    QNetworkReply *reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, this, &Backend::onChangeApiDbFileVisiblity);
}

void Backend::renameApiDbFile(const QString &fileId, const QString &newDbName)
{
    QUrl url(m_api_url);
    // Append query parameters to the URL
    QUrlQuery query;

    query.addQueryItem("request", "rename-db");
    query.addQueryItem("sessionKey", m_session_key);
    query.addQueryItem("fileId", fileId);
    query.addQueryItem("newName", newDbName);

    url.setQuery(query);

    QNetworkRequest request(url);

    // Send the GET request
    QNetworkReply *reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, this, &Backend::onRenameApiDbFile);
}

void Backend::deleteApiDbFile(const QString &fileId)
{
    QUrl url(m_api_url);
    // Append query parameters to the URL
    QUrlQuery query;

    query.addQueryItem("request", "remove-db");
    query.addQueryItem("sessionKey", m_session_key);
    query.addQueryItem("fileId", fileId);

    url.setQuery(query);

    QNetworkRequest request(url);

    // Send the GET request
    QNetworkReply *reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, this, &Backend::onDeleteApiDbFile);
}

int Backend::calculateStreakDays(QDate& currentDate)
{
    int streakCount = 0;

    // We'll check days going backwards starting from today
    while (true)
    {
        if (countActivitiesOfDate(currentDate) > 0)
        {
            // Practiced this day, increment streak and check previous day
            streakCount++;
            currentDate = currentDate.addDays(-1);
        }
        else
        {
            // No practice on this day, streak has broken
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

void Backend::setAndroidStatusBarColor(int r, int g, int b)
{
    androidControl.setStatusBarColor(r,g,b);
}

void Backend::setAndroidNavigationBarColor(int r, int g, int b)
{
    androidControl.setNavigationBarColor(r,g,b);
}

void Backend::hideAndroidNavigation()
{
    androidControl.hideNavigationBar();
}

void Backend::getWeeklyStats()
{
    QDate today = QDate::currentDate();
    int daysFromMonday = today.dayOfWeek() - 1;
    QDate monday = today.addDays(-daysFromMonday);
    qInfo() << "closest monday:" << monday.toString();

    //just rename monday to something better
    QDate* theDate = &monday;


    QList<float> totalMinutes = {0, 0, 0, 0, 0, 0, 0}; // Total hours per day (Mon-Sun)
    QList<int> totalMistakes = {0, 0, 0, 0, 0, 0, 0}; // Total mistakes per day (Mon-Sun)


    //init vars to avoid init inside loop
    QVariantList result;
    QString startOfDay, endOfDay, timeSpent;
    QVariantMap params, data;
    for(int i=0; i<7; i++)
    {
        // qInfo () << theDate->toString() << "'s activity count =" << countActivitiesOfDate(monday);

        //fetch and calculate total hours and total mistakes from week days
        startOfDay = theDate->toString("yyyy-MM-dd") + " 00:00:00";
        endOfDay = theDate->toString("yyyy-MM-dd") + " 23:59:59";
        params["start"] = startOfDay;
        params["end"] = endOfDay;

        result = m_db.runQueryGetVariantList(
            "SELECT tp_timeSpent, tp_mistakesCount FROM trace_practices WHERE tp_date BETWEEN :start AND :end",
            params
            );

        if (!result.isEmpty())
        {
            for (const QVariant &rowVar : result)
            {
                QVariantMap row = rowVar.toMap();

                totalMistakes[i] += row["tp_mistakesCount"].toInt();  // Mistakes count as an integer

                timeSpent = row["tp_timeSpent"].toString();  // Time spent as a string (e.g., "01:30:00")
                totalMinutes[i] += parseSpentTime(timeSpent);  // Assuming parseSpentTime is defined
                // qInfo() << "totalMinutes= " << totalMinutes[i] << "totalMistakes=" << totalMistakes[i];
            }
        }
        else
        {
            qInfo() << "Query did return an empty list!";
        }

        //go for next day
        *theDate = theDate->addDays(1);
    }
    emit getWeeklyStatsResult(totalMinutes,totalMistakes);
}

void Backend::makeCrossword()
{
    // Get the list of words
    QVariantList wordList = getTableWords();

    QVector<QString> verticalHint;
    QVector<QString> horizontalHint;

    //add words and their instruction to the wordText_Instruction
    QMap<QString,QString> wordText_Instruction;
    for (const QVariant &item : wordList)
    {
        if (item.canConvert<QVariantMap>())
        {
            QVariantMap map = item.toMap();
            QString textValue = map.value("text").toString();

            // QString textInstruction = map.value("picture").toString();
            // if(textInstruction.isEmpty())
            QString textInstruction = map.value("meaning").toString();


            wordText_Instruction.insert(textValue,textInstruction);
        }
    }



    //find most compatible word, [0]->compatibilityCount , [1]->word, [2]->meaning/picture
    QList<QString> coreWord = whatIsMostCompatible(wordText_Instruction);
    for (const QString& str : coreWord)
    {
        qDebug() << str;
    }



    //remove core-word from wordText_Instruction
    if (coreWord.size() > 0)
    {
        QString wordToRemove = coreWord[1];  // coreWord[0] is the word, coreWord[1] is its meaning

        wordText_Instruction.remove(wordToRemove);
        qInfo() << "core-word removed from list";
    }
    else
        qWarning() << "No core-word found to remove.";


    //build first empty grid with core-word length
    int gridSize = coreWord[1].length();
    QVector<QVector<QString>> gridWords(gridSize, QVector<QString>(gridSize, ""));
    qInfo() << "grid initialized size: " << gridSize << "grid:";
    printGrid(gridWords);



    //place core-word
    insertWordToGrid(gridWords,0, 0, coreWord[1], "h");
    horizontalHint.append(coreWord[2]);//add instruction/pic

    qInfo() << "core-word added:";
    printGrid(gridWords);



    //find most compatible words begins with core-word vertically
    QList<QVector<QString>> vertical_from_coreWord = whatAreCompatible(wordText_Instruction,"begin",coreWord[1]);
    qInfo() << "words starts with one letter of core-word=";
    for (const QVector<QString>& row : vertical_from_coreWord)
        qDebug() << "[" << row.join(", ") << "]";


    // List to store the chosen words from each group
    QList<QVector<QString>> chosenWords;
    int compatibilityCount = 0;
    int maxCompatibility = 0;

    // Sort vertical words based on the first character
    QList<QList<QVector<QString>>> vertical_sorted = sortedsortWordsBy("begin", vertical_from_coreWord);

    // Loop through each group in the sorted vertical list
    for (int i = 0; i < vertical_sorted.size(); ++i)
    {
        QList<QVector<QString>> group = vertical_sorted[i];

        qDebug() << "Group " << i + 1 << ":";

        // Reset maxCompatibility for each group
        maxCompatibility = 0;
        QVector<QString> bestWord;

        // Loop through each word in the current group
        for (const QVector<QString>& wordDef : group)
        {
            // Get the compatibility count for the current word
            compatibilityCount = whatAreCompatible(wordText_Instruction, "begin", wordDef[0]).size();

            qDebug() << "Word: " << wordDef[0] << ", Definition: " << wordDef[1] << " compatibility count: " << compatibilityCount;

            // If the compatibility count is higher than the current maximum, update maxCompatibility and store the word
            if (compatibilityCount > maxCompatibility)
            {
                maxCompatibility = compatibilityCount;
                bestWord = wordDef;  // Store the best word
            }
            // In case of a tie, you can decide to add the word or skip it
            // else if (compatibilityCount == maxCompatibility)
            // {
            //     bestWord = wordDef;  // Optionally handle ties here
            // }
        }

        // After processing the group, add the word with the highest compatibility to chosenWords
        if (!bestWord.isEmpty())
        {
            chosenWords.append(bestWord); // Add the word with the highest compatibility
        }

        qDebug() << "-------------------------------------------------------";
    }



    // Final result - chosen words (one from each group)
    qInfo() << "Chosen words with the highest compatibility count from each group:";
    for (const QVector<QString>& item : chosenWords)
    {
        qInfo() << item[0] << " " << item[1];
    }

    QString w_test = coreWord[1];
    QList<QVector<QString>> addedVertically;


    //extend hint vertor to beable call by index
    verticalHint.resize(coreWord[1].length());

    for (const QVector<QString>& item : chosenWords)
    {
        for(int x=0; x<w_test.length(); x++)
        {
            // qInfo() << "char=" << w_test[x] << " index:" << x;
            if(item[0][0] == w_test[x])
            {
                //add item to addedVertically to later know which words are vertically
                addedVertically.append(item);

                //remove item from choseWords to avoid duplicate and know this word is used
                chosenWords.removeOne(item);


                //insert
                insertWordToGrid(gridWords,0,x,item[0],"v");
                verticalHint[x] = item[1];//add instruction/pic
                // qInfo() << "word=" << item[0] << "hint=" << item[1];
            }

        }
    }

    qInfo() << "Vertical chosenWords added:";
    printGrid(gridWords);





    emit crosswordReady(getGridAs2DArray(gridWords),horizontalHint,verticalHint);
/*


    //remove vertical_from_coreWord from wordText_Instruction


    //returns those words are compatible with vectical, x,y position of the vertical's character
    QList<int, int, QVector<QString>> horizontal_to_vertical_reses =
            whatAreCompatible(wordText_Instruction,"horizontal","begin",vertical_from_coreWord);


    //place vertical
    //place horizontal

    emit crosswordReady(crosswordGrid);  // Emit the crossword grid with placed words

*/
}

void Backend::setTableAllRows(const QString &key, const QString &value)
{
    m_db.updateTableAllRows(currentTableName,key,value);
}



void Backend::getMonthStats()
{
    QDate today = QDate::currentDate();
    QDate startOfMonth = QDate(today.year(), today.month(), 1);  // Get the first day of the current month
    int lastDayOfMonth = startOfMonth.daysInMonth();  // Get the last day of the current month
    qInfo() << "Start of the month: " << startOfMonth.toString();
    qInfo() << "Last day of the month: " << lastDayOfMonth;

    // Initialize variables
    QList<float> totalMinutes(lastDayOfMonth, 0); // Total minutes for each day (1 to 31)
    QList<int> totalMistakes(lastDayOfMonth, 0);  // Total mistakes for each day (1 to 31)

    // Variables for the query
    QVariantList result;
    QString startOfDay, endOfDay, timeSpent;
    QVariantMap params, data;

    QDate* currentDay = &startOfMonth;  // Start from the first day of the month

    for (int i = 0; i < lastDayOfMonth; i++) {
        qInfo() << currentDay->toString() << "'s activity count =" << countActivitiesOfDate(*currentDay);

        // Fetch and calculate total hours and total mistakes for the current day
        startOfDay = currentDay->toString("yyyy-MM-dd") + " 00:00:00";
        endOfDay = currentDay->toString("yyyy-MM-dd") + " 23:59:59";
        params["start"] = startOfDay;
        params["end"] = endOfDay;

        result = m_db.runQueryGetVariantList(
            "SELECT tp_timeSpent, tp_mistakesCount FROM trace_practices WHERE tp_date BETWEEN :start AND :end",
            params
            );

        if (!result.isEmpty()) {
            for (const QVariant &rowVar : result) {
                QVariantMap row = rowVar.toMap();
                totalMistakes[i] += row["tp_mistakesCount"].toInt();  // Mistakes count as an integer

                timeSpent = row["tp_timeSpent"].toString();  // Time spent as a string (e.g., "01:30:00")
                totalMinutes[i] += parseSpentTime(timeSpent);  // Assuming parseSpentTime is defined
                qInfo() << "totalMinutes= " << totalMinutes[i] << " totalMistakes=" << totalMistakes[i];
            }
        } else {
            qInfo() << "Query did not return any results!";
        }

        // Move to the next day
        *currentDay = currentDay->addDays(1);
    }

    // Emit results for all days in the current month
    emit getMonthStatsResult(totalMinutes, totalMistakes);
}

float Backend::parseSpentTime(const QString &spentTime)
{
    QStringList timeParts = spentTime.split(":");
    if (timeParts.size() == 3)
    {
        int hours = timeParts[0].toInt();
        int minutes = timeParts[1].toInt();
        int seconds = timeParts[2].toInt();

        // Calculate the total time in minutes (including fractional part for seconds)
        return (hours * 60) + minutes + (seconds / 60.0);  // Return minutes as a float
    }
    return 0;
}


int Backend::countActivitiesOfDate(QDate &date)
{
    QString startOfDay = date.toString("yyyy-MM-dd") + " 00:00:00";
    QString endOfDay = date.toString("yyyy-MM-dd") + " 23:59:59";

    QVariantMap params;
    params["start"] = startOfDay;
    params["end"] = endOfDay;

    QVariant result = m_db.runQuery(
        "SELECT COUNT(*) FROM trace_practices WHERE tp_date BETWEEN :start AND :end",
        params
        );

    if (result.isValid())
    {
        int count = result.toInt();
        if (count > 0)
            return count;
    }

    return 0;
}


QList<QString> Backend::whatIsMostCompatible(const QMap<QString, QString>& wordText_Instruction)
{
    QList<QString> result;

    QMap<int, QPair<QString, QString>> scoreBoard;

    // Iterate through each key-value pair in the QMap
    for (auto it = wordText_Instruction.begin(); it != wordText_Instruction.end(); ++it)
    {
        QString key = it.key();
        QString key2;
        int compatibilityCount = 0;

        // Compare the current key with all other keys
        for (auto it2 = wordText_Instruction.begin(); it2 != wordText_Instruction.end(); ++it2)
        {
            key2=it2.key();
            // Skip comparing the key to itself
            if (it == it2) continue;

            for(int i=0; i<key2.length(); i++)
            {
                if(key.contains(key2[i]))
                {
                    compatibilityCount++;
                }
            }
        }
        scoreBoard.insert(compatibilityCount, QPair<QString, QString>(it.key(), it.value()));
    }


    //assuming first item is bigger.
    int max= scoreBoard.begin().key();
    QString t=scoreBoard.begin().value().first;
    QString v=scoreBoard.begin().value().second;

    //find the most compatible word
    for (auto it = scoreBoard.begin(); it != scoreBoard.end(); ++it)
    {
        // qDebug() << "compatibilityCount:" << it.key() << ", key:" << it.value().first << ", val:" << it.value().second;
        if(max<it.key())
        {
            max=it.key();
            t=it.value().first;
            v=it.value().second;
        }
    }

    qInfo() << "condidated = " << max << " text=" << t << " val=" << v;
    result.append(QString::number(max));
    result.append(t);
    result.append(v);
    return result;
}


void Backend::printGrid(const QVector<QVector<QString>>& grid)
{
    // Iterate through each row in the grid
    for (int i = 0; i < grid.size(); ++i)
    {
        QString row;  // To accumulate the row's elements

        // Iterate through each column in the row
        for (int j = 0; j < grid[i].size(); ++j)
        {
            // Append the element to the row string
            row += grid[i][j];

            // Add a space between elements in the same row, but not after the last element
            if (j < grid[i].size() - 1)
            {
                row += ",";
            }
        }

        // Print the row with a newline at the end
        qInfo() << row;  // Print the whole row in one line
    }
}

void Backend::insertWordToGrid(QVector<QVector<QString>>& gridWords, int x, int y, const QString& word, QString mode)
{
    // Ensure the word fits within the current grid bounds
    int wordLength = word.length();
    int gridSize = gridWords.size();

    // Check if the grid is large enough to accommodate the word
    if (mode == "h") {
        // Horizontal: Check if there are enough columns
        if (y + wordLength > gridSize) {
            // Expand the grid horizontally (increase the number of columns)
            int newCols = y + wordLength;
            for (int i = 0; i < gridSize; ++i) {
                gridWords[i].resize(newCols, "");
            }
        }
    } else if (mode == "v") {
        // Vertical: Check if there are enough rows
        if (x + wordLength > gridSize) {
            // Expand the grid vertically (increase the number of rows)
            int newRows = x + wordLength;
            gridWords.resize(newRows);

            // Ensure all rows have the correct number of columns
            for (int i = 0; i < newRows; ++i) {
                if (gridWords[i].size() < gridSize) {
                    gridWords[i].resize(gridSize, "");
                }
            }
        }
    }

    // Now insert the word in the specified mode (horizontal or vertical)
    for (int i = 0; i < wordLength; i++) {
        if (mode == "h") {  // Horizontal insertion
            gridWords[x][y + i] = word[i];
        } else {  // Vertical insertion
            gridWords[x + i][y] = word[i];
        }
    }

    qInfo() << "Inserted word '" << word << "' at position (" << x << ", " << y << ") in " << mode << " direction.";
}


QVector<QVector<QString>> Backend::Backend::getGridAs2DArray(const QVector<QVector<QString> > &gridWords)
{
    QVector<QVector<QString>> result;

    // Iterate through each row of the grid
    for (const auto& row : gridWords)
    {
        QVector<QString> rowResult;

        // Iterate through each cell of the row
        for (const auto& cell : row)
        {
            if (cell.isEmpty())
                rowResult.append("");  // Add an empty string for empty cells
            else
                rowResult.append(cell);  // Add the word/letter in non-empty cells
        }

        // Add the processed row to the result
        result.append(rowResult);
    }

    return result;
}

QList<QVector<QString>> Backend::whatAreCompatible(const QMap<QString, QString> &wordlist,
                                                   QString beginOrEnds, QString targetWord)
{
    QList<QVector<QString>> result;
    QVector<QString> row;
    for (auto it = wordlist.begin(); it != wordlist.end(); ++it)
    {
        for(int i=0; i<targetWord.length(); i++)
        {
            //check for same word
            if(it.key()[0]==targetWord)
                continue;

            if(beginOrEnds=="begin")//begins with
            {
                if(targetWord[i] == it.key()[0])
                {


                    row.clear();
                    row.push_back(it.key());
                    row.push_back(it.value());

                    //check for duplicates
                    if(!result.contains(row))
                        result.append(row);

                }
            }
            else //ends with
            {
                if(targetWord[i] == it.key()[it.key().length()-1])
                {
                    row.clear();
                    row.push_back(it.key());
                    row.push_back(it.value());

                    //check for duplicates
                    if(!result.contains(row))
                        result.append(row);

                }
            }
        }
    }

    return result;
}

QList<QList<QVector<QString>>> Backend::sortedsortWordsBy(const QString &beginOrEnd, const QList<QVector<QString>> &list)
{
    QList<QList<QVector<QString>>> result;

    // Helper function to get the first or last character of a word
    auto getSortChar = [&beginOrEnd](const QString &word) -> QChar {
        if (beginOrEnd == "begin") {
            // Return the first character
            return word.trimmed().at(0);
        } else if (beginOrEnd == "end") {
            // Return the last character
            return word.trimmed().at(word.length() - 1);
        }
        return QChar();
    };

    // Map to store groups of words based on their first or last character
    QMap<QChar, QList<QVector<QString>>> sortedWords;

    for (const QVector<QString> &wordDef : list) {
        QString word = wordDef[0];  // The first element in each QVector is the word
        QChar keyChar = getSortChar(word);

        if (keyChar.isLetter()) {
            sortedWords[keyChar].append(wordDef);
        }
    }

    // Prepare the result by converting the QMap into a QList<QList<QVector<QString>>>
    for (auto it = sortedWords.begin(); it != sortedWords.end(); ++it) {
        result.append(it.value());
    }

    return result;
}

bool Backend::getNextMatchingWord(const QString& status)
{
    while (last_id < max_id)
    {
        last_id++;
        current_word = m_db.searchTable(currentTableName, "id", QString::number(last_id));

        if (current_word.isEmpty()) continue;

        QString wordStatus = current_word[0].value("status").toString();
        if (status == "all" || wordStatus == status)
        {
            return true; // found valid word
        }
    }

    return false; // no valid word found
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

void Backend::signAccount(const QString &requestType, const QString &username, const QString &password, const QString &email)
{
    QUrl url(m_api_url);
    // Append query parameters to the URL
    QUrlQuery query;

    query.addQueryItem("request", requestType);

    if (!m_session_key.isEmpty())
        query.addQueryItem("sessionKey", m_session_key);
    if (!username.isEmpty())
    {
        settings.setValue("username",username); //save username on local settings
        query.addQueryItem("username", username);
    }
    if (!password.isEmpty())
        query.addQueryItem("password", password);
    if (!email.isEmpty())
        query.addQueryItem("email", email);

    url.setQuery(query);

    QNetworkRequest request(url);

    // Send the GET request
    QNetworkReply *reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, this, &Backend::onSignResult);
}

void Backend::isSessionValid()
{
    QUrl url(m_api_url);
    // Append query parameters to the URL
    QUrlQuery query;

    query.addQueryItem("request", "pingSession");

    if (!m_session_key.isEmpty())
        query.addQueryItem("sessionKey", m_session_key);
    else
        emit signResult("sessionKey not found");

    url.setQuery(query);

    QNetworkRequest request(url);

    // Send the GET request
    QNetworkReply *reply = m_networkManager.get(request);
    connect(reply, &QNetworkReply::finished, this, &Backend::onSignResult);
}



void Backend::deleteTable(const QString& tableName)
{
    //delete table from user_tables
    bool status = m_db.removeRow("user_tables","t_title",tableName);
    if(status)
    {
        status = m_db.removeTable(tableName);

        //remove content of table
        bool removeDirStatus = localFileManager.removeDirectoryAndContains(whatIsCurrentDatabase()+"_"+tableName);
        if(removeDirStatus)
            qInfo() << "table data removed.";
        else
            qInfo() <<"failed to remove table data";
    }

    //delete table by sql
    emit tableRemovalResult(status);
}

QString Backend::changeTableStatus(const int &tableId, const QString &status)
{
    //change field t_status at user_tables to (status)
    QString qresult="error";
    QString newStatus;

    if(status=="archive")
        newStatus="archived";
    else if(status=="pin")
        newStatus="pinned";
    else if(status=="unpin" ||  status=="unarchive")
        newStatus="0";
    else
        qInfo() <<"changeTableStatus: unknown status type";


    bool qResult = m_db.updateTableValue("user_tables","t_id",tableId,"t_status",newStatus);
    if(qResult)
        qresult = "table status has been updated to" + newStatus;

    return qresult;
}

void Backend::renameTable(const QString &tableName, const QString &newName)
{
    //delete table from user_tables
    QString result;
    bool qResult = m_db.renameTable(tableName,newName);
    if(qResult)
    {
        result = "succeed to rename table";
        qResult = m_db.updateTableValue("user_tables","t_title",tableName,"t_title",newName);
        if(qResult)
        {
            result += " and succeed to rename table on uesr_tables";
            QString dbn = whatIsCurrentDatabase() + "_";
            bool renameDirRes = localFileManager.renameDirectory(dbn+tableName,dbn+newName);
            if(renameDirRes)
                result += " and content directory renamed";
            else
                result += " and couldnt rename content directory";
        }

        else
            result += " but failed to rename table on user_tables";
    }
    else
        result = "failed to rename table";

    emit tableRenameResult(qResult,result);
}


void Backend::onUrlListReceived()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply)
    {
        qInfo() << "Error: Sender is not a valid QNetworkReply!";
        emit urlListFailed("Error: Sender is not a valid QNetworkReply!");
        return;
    }

    QString resultMessage;
    QString resultError;
    QVariantList urlList;

    // Check for network error first
    if (reply->error() != QNetworkReply::NoError)
    {
        qInfo() << "Network error: " << reply->errorString();
        reply->deleteLater();
        emit urlListFailed("Network error: " + reply->errorString());
        return;
    }

    // To Check the HTTP status code and response manually
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    qInfo() << "HTTP Status Code: " << statusCode;
    QByteArray response = reply->readAll();
    qInfo() << "Response: " << response;

    // Parse the response as a JSON document
    QJsonDocument doc = QJsonDocument::fromJson(response);

    // Check if the document is an array or an object
    if (doc.isArray())
    {
        // Handle JSON array
        qInfo() << "Handle JSON array";
        QJsonArray arr = doc.array();
        for (const auto &item : arr)
        {
            if (item.isObject())
            {
                QJsonObject obj = item.toObject();
                resultError = obj["error"].toString();
                resultMessage = obj["message"].toString();
                qInfo() << "onUrlListReceived, resultError=" << resultError << "message=" << resultMessage;

                QVariantMap map;
                map["d_id"] = obj["d_id"].toString();
                map["d_name"] = obj["d_name"].toString();
                map["d_url"] = obj["d_url"].toString();
                map["d_icon"] = obj["d_icon"].toString();
                map["d_visibility"] = obj["d_visibility"].toString();
                map["d_owner"] = obj["d_owner"].toString();
                map["d_type"] = obj["d_type"].toString();


                urlList.append(map);
            }
            else
            {
                qInfo() << "Array item is not a valid object";
                resultError = "Array item is not a valid object";
            }
        }
        // Emit the URL list
        emit urlListReady(urlList);
        return;
    }
    else if (doc.isObject())
    {
        // Handle JSON object
        qInfo() << "Handle JSON object";
        QJsonObject obj = doc.object();

        // Ensure the JSON object contains the expected data
        if (obj.contains("d_name") && obj.contains("d_url") && obj.contains("d_icon"))
        {
            QVariantMap map;
            map["d_id"] = obj["d_id"].toString();
            map["d_name"] = obj["d_name"].toString();
            map["d_url"] = obj["d_url"].toString();
            map["d_icon"] = obj["d_icon"].toString();
            map["d_visibility"] = obj["d_visibility"].toString();
            map["d_owner"] = obj["d_owner"].toString();

            urlList.append(map);

            // Emit the URL list
            emit urlListReady(urlList);
            return;
        }
        else if(obj.contains("error") || obj.contains("message"))
        {
            resultError = obj["error"].toString();
            resultMessage = obj["message"].toString();
            // Emit the URL list
            emit urlListFailed(resultMessage.isEmpty() ? resultError : resultMessage);
            return;
        }
        else
        {
            qInfo() << "Missing expected keys in the response object.";
            resultError = "Missing expected keys in the response object.";
        }
    }
    else
    {
        // Handle unexpected JSON format
        qInfo() << "Unexpected response format: Neither an object nor an array.";
        resultError = "Unexpected response format";
    }

    // Emit error
    reply->deleteLater();
    emit urlListFailed(resultError);
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

void Backend::onSignResult()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) {
        qInfo() << "Error: Sender is not a valid QNetworkReply!";
        return;
    }

    QString resultMessage;
    QString resultError;
    QString resultKey;

    // Check for network error first
    if (reply->error() != QNetworkReply::NoError) {
        qInfo() << "Network error: " << reply->errorString();
        reply->deleteLater();
        emit signResult("Network error: " + reply->errorString());
        return;
    }

    // Check the HTTP status code
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    qInfo() << "HTTP Status Code: " << statusCode;

    // Read and print the response body
    QByteArray response = reply->readAll();
    qInfo() << "Response: " << response;

    // Parse the response as a JSON document
    QJsonDocument doc = QJsonDocument::fromJson(response);

    // Check if the document is an array or an object
    if (doc.isArray())
    {
        // Handle JSON array
        QJsonArray arr = doc.array();
        for (const auto &item : arr) {
            if (item.isObject()) {
                QJsonObject obj = item.toObject();
                resultError = obj["error"].toString();
                resultMessage = obj["message"].toString();
                resultKey = obj["sessionKey"].toString();
                qInfo() << "onSignResult, resultError=" << resultError << "message=" << resultMessage << "key=" << resultKey;
            } else {
                qInfo() << "Array item is not a valid object";
            }
        }
    }
    else if (doc.isObject())
    {
        // Handle JSON object
        QJsonObject obj = doc.object();
        resultError = obj["error"].toString();
        resultMessage = obj["message"].toString();
        resultKey = obj["sessionKey"].toString();
        qInfo() << "onSignResult, resultError=" << resultError << "message=" << resultMessage << "key=" << resultKey;
    } else {
        // Handle unexpected JSON format
        qInfo() << "Unexpected response format: Neither an object nor an array.";
        resultError = "Unexpected response format";
    }

    // Emit result or error
    reply->deleteLater();
    if (!resultError.isEmpty()) {
        emit signResult(resultError);  // Pass the error message if present
    } else {
        emit signResult(resultMessage.isEmpty() ? resultKey : resultMessage);  // Pass the message or sessionKey
    }
}

void Backend::onTTSResult(const bool &result, const QString fname)
{
    emit ttsDone(result,fname);
}

void Backend::onRenameApiDbFile()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) {
        qInfo() << "Error: Sender is not a valid QNetworkReply!";
        return;
    }

    QString resultMessage;
    QString resultError;
    QString resultKey;

    // Check for network error first
    if (reply->error() != QNetworkReply::NoError) {
        qInfo() << "Network error: " << reply->errorString();
        reply->deleteLater();
        emit signResult("Network error: " + reply->errorString());
        return;
    }

    // Check the HTTP status code
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    qInfo() << "HTTP Status Code: " << statusCode;

    // Read and print the response body
    QByteArray response = reply->readAll();
    qInfo() << "Response: " << response;

    // Parse the response as a JSON document
    QJsonDocument doc = QJsonDocument::fromJson(response);

    // Check if the document is an array or an object
    if (doc.isArray())
    {
        // Handle JSON array
        QJsonArray arr = doc.array();
        for (const auto &item : arr) {
            if (item.isObject()) {
                QJsonObject obj = item.toObject();
                resultError = obj["error"].toString();
                resultMessage = obj["message"].toString();
                qInfo() << "onRenameApiDbFile, resultError=" << resultError << "message=" << resultMessage << "key=" << resultKey;
            } else {
                qInfo() << "Array item is not a valid object";
            }
        }
    }
    else if (doc.isObject())
    {
        // Handle JSON object
        QJsonObject obj = doc.object();
        resultError = obj["error"].toString();
        resultMessage = obj["message"].toString();
        qInfo() << "onRenameApiDbFile, resultError=" << resultError << "message=" << resultMessage << "key=" << resultKey;
    }
    else {
        // Handle unexpected JSON format
        qInfo() << "Unexpected response format: Neither an object nor an array.";
        resultError = "Unexpected response format";
    }

    // Emit result or error
    reply->deleteLater();
    if (!resultError.isEmpty()) {
        emit renameApiDbFileResult(resultError);
    } else {
        emit renameApiDbFileResult(resultMessage);
    }
}

void Backend::onChangeApiDbFileVisiblity()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) {
        qInfo() << "Error: Sender is not a valid QNetworkReply!";
        return;
    }

    QString resultMessage;
    QString resultError;
    QString resultKey;

    // Check for network error first
    if (reply->error() != QNetworkReply::NoError) {
        qInfo() << "Network error: " << reply->errorString();
        reply->deleteLater();
        emit signResult("Network error: " + reply->errorString());
        return;
    }

    // Check the HTTP status code
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    qInfo() << "HTTP Status Code: " << statusCode;

    // Read and print the response body
    QByteArray response = reply->readAll();
    qInfo() << "Response: " << response;

    // Parse the response as a JSON document
    QJsonDocument doc = QJsonDocument::fromJson(response);

    // Check if the document is an array or an object
    if (doc.isArray())
    {
        // Handle JSON array
        QJsonArray arr = doc.array();
        for (const auto &item : arr) {
            if (item.isObject()) {
                QJsonObject obj = item.toObject();
                resultError = obj["error"].toString();
                resultMessage = obj["message"].toString();
                qInfo() << "onChangeApiDbFileVisiblity, resultError=" << resultError << "message=" << resultMessage << "key=" << resultKey;
            } else {
                qInfo() << "Array item is not a valid object";
            }
        }
    }
    else if (doc.isObject())
    {
        // Handle JSON object
        QJsonObject obj = doc.object();
        resultError = obj["error"].toString();
        resultMessage = obj["message"].toString();
        qInfo() << "onChangeApiDbFileVisiblity, resultError=" << resultError << "message=" << resultMessage << "key=" << resultKey;
    }
    else {
        // Handle unexpected JSON format
        qInfo() << "Unexpected response format: Neither an object nor an array.";
        resultError = "Unexpected response format";
    }

    // Emit result or error
    reply->deleteLater();
    if (!resultError.isEmpty()) {
        emit changeApiDbFileVisiblityResult(resultError);
    } else {
        emit changeApiDbFileVisiblityResult(resultMessage);
    }
}


void Backend::onDeleteApiDbFile()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) {
        qInfo() << "Error: Sender is not a valid QNetworkReply!";
        return;
    }

    QString resultMessage;
    QString resultError;
    QString resultKey;

    // Check for network error first
    if (reply->error() != QNetworkReply::NoError) {
        qInfo() << "Network error: " << reply->errorString();
        reply->deleteLater();
        emit signResult("Network error: " + reply->errorString());
        return;
    }

    // Check the HTTP status code
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    qInfo() << "HTTP Status Code: " << statusCode;

    // Read and print the response body
    QByteArray response = reply->readAll();
    qInfo() << "Response: " << response;

    // Parse the response as a JSON document
    QJsonDocument doc = QJsonDocument::fromJson(response);

    // Check if the document is an array or an object
    if (doc.isArray())
    {
        // Handle JSON array
        QJsonArray arr = doc.array();
        for (const auto &item : arr) {
            if (item.isObject()) {
                QJsonObject obj = item.toObject();
                resultError = obj["error"].toString();
                resultMessage = obj["message"].toString();
                qInfo() << "onDeleteApiDbFile, resultError=" << resultError << "message=" << resultMessage << "key=" << resultKey;
            } else {
                qInfo() << "Array item is not a valid object";
            }
        }
    }
    else if (doc.isObject())
    {
        // Handle JSON object
        QJsonObject obj = doc.object();
        resultError = obj["error"].toString();
        resultMessage = obj["message"].toString();
        qInfo() << "onDeleteApiDbFile, resultError=" << resultError << "message=" << resultMessage << "key=" << resultKey;
    }
    else {
        // Handle unexpected JSON format
        qInfo() << "Unexpected response format: Neither an object nor an array.";
        resultError = "Unexpected response format";
    }

    // Emit result or error
    reply->deleteLater();
    if (!resultError.isEmpty()) {
        emit deleteApiDbFileResult(resultError);
    } else {
        emit deleteApiDbFileResult(resultMessage);
    }
}

void Backend::onLatestTableContentFileName(QString fName)
{
    //check for response
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    if (!reply) {
        qInfo() << "Error: Sender is not a valid QNetworkReply!";
        return;
    }

    QString resultMessage;
    QString resultError;
    QString resultKey;

    // Check for network error first
    if (reply->error() != QNetworkReply::NoError) {
        qInfo() << "Network error: " << reply->errorString();
        reply->deleteLater();
        emit signResult("Network error: " + reply->errorString());
        return;
    }

    // Check the HTTP status code
    int statusCode = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
    qInfo() << "HTTP Status Code: " << statusCode;

    // Read and print the response body
    QByteArray response = reply->readAll();
    qInfo() << "Response: " << response;

    // Parse the response as a JSON document
    QJsonDocument doc = QJsonDocument::fromJson(response);

    // Check if the document is an array or an object
    if (doc.isArray())
    {
        // Handle JSON array
        QJsonArray arr = doc.array();
        for (const auto &item : arr) {
            if (item.isObject()) {
                QJsonObject obj = item.toObject();
                resultError = obj["error"].toString();
                resultMessage = obj["message"].toString();
            } else {
                qInfo() << "Array item is not a valid object";
            }
        }
    }
    else if (doc.isObject())
    {
        // Handle JSON object
        QJsonObject obj = doc.object();
        resultError = obj["error"].toString();
        resultMessage = obj["message"].toString();
    }
    else {
        // Handle unexpected JSON format
        qInfo() << "Unexpected response format: Neither an object nor an array.";
        resultError = "Unexpected response format";
    }

    // Emit result or error
    reply->deleteLater();
    if (!resultError.isEmpty()) {
        qInfo() << "failed to download tableContent resultError=" << resultError;
    } else {
        //request for download file and read status of download from QML
        download(resultMessage,fName,true);
    }
}



