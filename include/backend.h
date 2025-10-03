#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QStandardPaths>

#include "database.h"
#include "settingsmanager.h"


#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include "filemanager.h"

#include <QRandomGenerator>
#include <QUrlQuery>

#include "localfilemanager.h"

/*!
 * \class Backend
 * \brief This class contains the core backend logic and acts as a bridge between QML and various backend components.
 *
 *
 * It is designed to simplify QML integration by providing a single access point,
 * reducing the need to reference multiple C++ class names directly in QML.
 */
class Backend : public QObject
{
    Q_OBJECT
    DataBase m_db;
    QString currentTableName;
    QString currentTableType;
    QString databaseFullPath;

    int currentStreakCount;
    QDate lastPracticeDate;

    QString m_contentPath;

    QString m_api_url;
    QString m_username;
    QString m_session_key;
    QString m_dbPath;
    SettingsManager settings;


    QNetworkAccessManager m_networkManager;
    FileManager m_fileManager;

    int min_id;
    int max_id;
    int last_id;
    QSqlQuery* m_query;
    QList<QMap<QString, QVariant>> current_word;


    LocalFileManager localFileManager;



    int calculateStreakDays(QDate& currentDate);
    QDate getLastActivityDate();

    /*!
     * \brief convert h:m:s time string to total minutes
     * \param string time like hh:mm:ss
     * \return minutes
     */
    float parseSpentTime(const QString &spentTime);


    /*!
     * \brief counts activities of given date
     * \param a date
     * \return activity total count
     */
    int countActivitiesOfDate(QDate& date);


    bool removeFile(const QString& filepath);








    //crossword

    QList<QString> whatIsMostCompatible(const QMap<QString,QString>& wordText_Instruction);
    void printGrid(const QVector<QVector<QString>>& grid);
    void insertWordToGrid(QVector<QVector<QString>>& gridWords, int x, int y, const QString &word,QString mode);
    QVector<QVector<QString>> getGridAs2DArray(const QVector<QVector<QString>>& gridWords);
    QList<QVector<QString>> whatAreCompatible(const QMap<QString,QString>& wordlist, QString beginOrEnds, QString targetWord);
    QList<QList<QVector<QString>>> sortedsortWordsBy(const QString& beginOrEnd, const QList<QVector<QString>>& list);
public:

    /*!
     * \brief to calculate activity of week (mistaksCount, timeSpent as hour) from trace_practices
     * \return emits getWeeklyStatsResult to pass (Total Minutes List , Total Mistakes List)
     */
    Q_INVOKABLE void getWeeklyStats();


    Q_INVOKABLE void makeCrossword();



    /*!
     * \brief to calculate activity of month (mistaksCount, timeSpent as hour) from trace_practices
     * \return emits getMonthStatsResult to pass (Total Minutes List , Total Mistakes List)
     */
    Q_INVOKABLE void getMonthStats();


    /*!
     * \brief init database (used to open/create/switch database), and initial important sql tables and set some variables also calls settings.init()
     * \param databaseName if not provided, it will read it from default/set value at settings.getValue("currentDatabase")
     * \return in failure to switch/create/open returns false.
     */
    bool init(QString databaseName="");


    /*!
     * \brief init program and connect signals
     * \param parent Optional QObject parent (default is nullptr).
     */
    explicit Backend(QObject *parent = nullptr);

    /*!
     * \brief to read word from practice in series, it starts from index 0 to maxindex of that table then validate entered text if it matches will return next word to user
     * \param entered text from user, modify status(in case when inside practice user decided to modify that word turn this on to add another attemp to receive new word from db and check correction of new word with entered one)
     * \return maxId of that table also emits wordIsIncorrect("incorrect") when word doesn't mactch or wordReady(row of word as list)
     */
    Q_INVOKABLE int getNextWord(const QString& userText, const bool& isModified=false);

    /*!
     * \brief to get next word without checking user input is correct/incorrect.
     * \return emits wordReady with QList of next word
     */
    Q_INVOKABLE void getNextWord();

    QVariantList getTableWords();



    Q_INVOKABLE QString getSetting(const QString& settingKey);
    Q_INVOKABLE void setSetting(const QString& settingKey,const QString& settingValue);


    Q_INVOKABLE QString getVersion();

    /*!
     * \brief to trace practice by submitting them inside table (trace_practices)
     * \param mistake count made inside practice, timeSpent in practice (e.g: 00:15:25),  practiceType(e.g: 1->typePractice, 2->flashcardPractice)
     */
    Q_INVOKABLE void setPracticeResult(const QString& mistakeCount, const QString& timeSpent, const int& practiceType);

    /*!
     * \brief to get tables list from sql table (user_tables) those with t_status pinned are in priority and those with t_status=archived won't add
     * \param searchedTitle(optional to filter table names), tableType (to filter tables type, default:all tables), types can be (all,verb,word,archives) "archives" actually isn't a type but it's a filed inside user_tables.t_status and used to access/list to archived
     * \return emit tablesList(tableList)
     */
    Q_INVOKABLE void getTables(const QString& searchedTitle, const QString& tableType);

    Q_INVOKABLE void getLessonsList();

    /*!
     * \brief to create a sql table and add it into (user_tables)
     * \param table-name and table-type(e.g: verb,word) wants to create
     * \return emit tableCreationResult(result), in failure pass "error" else pass message with details
     */
    Q_INVOKABLE void createTable(const QString& tableName, const QString& tableType);

    /*!
     * \brief to switch between tables, will set variables (currentTableName and currentTableType) and call resetPractice() for other functions use later
     * \param tableName: table wants to switch, tableType: type of table (e.g: verb/word)
     */
    Q_INVOKABLE void switchTable(const QString& tableName, const QString& ttype);

    /*!
     * \brief it will call init() and pass with entered database name to create database file if doesn't exist
     * \param database name wants to create
     * \return emit databaseCreationResult with result of creation
     */
    Q_INVOKABLE void createDatabase(const QString& databaseName);

    /*!
     * \brief it will check existant of entered name then if chosen name is currentDatabase switch data to a random one, then remove it, if chosen one was only one database it will abort to delete
     * \param database name wants to delete
     * \return emit databaseRemoveResult with result of delete
     */
    Q_INVOKABLE void removeDatabase(const QString& databaseName);


    /*!
     * \brief to know what is selected/current table type
     * \return emit tableTypeIs with variable currentTableType
     */
    Q_INVOKABLE void whatIsCurrentTableType();

    /*!
     * \brief to add a word into a table
     * \param list of word in speicific order indexes depends on tableType
     * \return emit addItemtoTableResult with result, in failure will return "error" else will return a message
     */
    Q_INVOKABLE void addWordToTable(const QStringList& data);


    /*!
     * \brief to update a word in a table
     * \param wordId, tableType(e.g: word/verb) and list of word in speicific order indexes depends on tableType
     * \return emit modifyWordOnTableResult with result, in failure will return "error" else will return a message
     */
    Q_INVOKABLE void modifyWordOnTable(const int& targetWordId, const QString& tagetTableType, const QStringList& data);


    /*!
     * \brief to reset variables for next practice round
     */
    Q_INVOKABLE void resetPractice();

    /*!
     * \brief to get value of current database (databaseFullPath)
     * \return full database path (e.g /home/userName/...)
     */
    Q_INVOKABLE QString databasePath();


    /*!
     * \brief to search for exist files inside app databases path and remove format .sqlite from them
     * \return a list of existed files
     */
    Q_INVOKABLE QStringList listOfDatabases();


    /*!
     * \brief to switch between databases by calling init(), and will re-assign qsetting(currentDatabase)
     * \param that database name want to switch to
     * \return "successed" or "failed"
     */
    Q_INVOKABLE QString switchDatabase(const QString& databaseName);


    /*!
     * \brief to get current database storaged at qsetting
     * \return current database value from qsetting(currentDatabase)
     */
    Q_INVOKABLE QString whatIsCurrentDatabase();

    /*!
     * \brief getter for m_api_url
     * \return value of m_api_url
     */
    Q_INVOKABLE QString getApiUrl();

    /*!
     * \brief getter for m_session_key
     * \return value of m_session_key
     */
    Q_INVOKABLE QString getSessionKey();


    Q_INVOKABLE QString getUsername();

    /*!
     * \brief setter for m_api_url and save it by qsettings(api_url)
     * \param new api url
     */
    Q_INVOKABLE void setApiUrl(const QString& apiURL);

    /*!
     * \brief setter for m_session_key and save it by qsettings(api_key)
     * \param new api key
     */
    Q_INVOKABLE void setSessionKey(const QString& sessionKey);

    /*!
     * \brief will send sessionKey to apiurl by using QNetworkAccessManager then connects finished to onUrlListReceived to return list of received json from web api
     */
    Q_INVOKABLE void fetchUrlList(const QString& visibilityFilter);

    /*!
     * \brief to download a file and call signals onDownloadFinished,onDownloadProgress (already we have connected these inside Backend Constructor with private ones to notify user of download status)
     */
    Q_INVOKABLE void download(const QString &url, const QString &fileName,
                              bool overwriteFileName=false);


    Q_INVOKABLE void uploadFileToApi(const QString& fileName, const QString& publicStatus);
    Q_INVOKABLE void overwriteFileToApi(const QString& fileName);
    Q_INVOKABLE void syncDatabaseWithApi(const QString& fileName);

    Q_INVOKABLE QString getThemeMode();
    Q_INVOKABLE void setThemeMode(const QString& themeTitle);
    Q_INVOKABLE int getLastWindowSize(const QString& widthOrHeight);
    Q_INVOKABLE void setLastWindowSize(const QString& wOrh , const int &value);

    /*!
     * \return emits signResult( responded message or sessionkey)
     */
    Q_INVOKABLE void signAccount(const QString& requestType, const QString& username="", const QString& password="", const QString& email="");
    Q_INVOKABLE void isSessionValid();

    /*!
     * \brief to get a list of total streak days and seven value to display status of streak to user.
     * \return a list which has first item as (total streak days) and rest of them are week status filled with three value: active:1, inactive:0, upcoming:?
     */
    Q_INVOKABLE QStringList getStreakDays();


    /*!
     * \brief to delete a table also delete it from table (user_tables)
     * \param that table name wants to remove
     * \return will emit tableRemovalResult(status) and pass a boolean
     */
    Q_INVOKABLE void deleteTable(const QString& tableName);


    /*!
     * \brief to change/switch status a table to pinned/archived/... at table (user_tables)
     * \param table id, status (can be archive/pin/unpin/unarchive)
     * \return if action failed will be "error" else will be message detailed
     */
    Q_INVOKABLE QString changeTableStatus(const int& tableId, const QString& status="0");

    Q_INVOKABLE void renameTable(const QString &tableName, const QString& newName);

    Q_INVOKABLE QString getContentPath() const;


    Q_INVOKABLE void changeApiDbFileVisiblity(const QString& fileId, const QString& newStatus);
    Q_INVOKABLE void renameApiDbFile(const QString& fileId, const QString& newDbName);
    Q_INVOKABLE void deleteApiDbFile(const QString& fileId);


signals:
    void wordReady(const QList<QMap<QString, QVariant>>& word);
    void crosswordReady(const QVector<QVector<QString>>& crossword);
    void practiceFinished();
    void wordIsIncorrect(const QString& correctStatus);
    void tablesList(const QVariantList& tableList);
    void lessonList(const QVariantList& tableList);

    void tableCreationResult(const QString& tableCreationResult);
    void databaseCreationResult(const QString& databaseCreationResult);
    void databaseRemoveResult(const bool& result);
    void tableTypeIs(const QString& currentTableType);
    void addItemtoTableResult(const QString& result);
    void modifyWordOnTableResult(const QString& result);


    void urlListReady(const QVariantList &list);
    void urlListFailed(const QString &errorString);
    void downloadProgress(qint64 bytesReceived, qint64 bytesTotal);
    void downloadFinished(bool success, const QString &filePath);
    void uploadDone(const QString& result);

    void tableRemovalResult(const bool& result);
    void tableRenameResult(const bool& status, const QString& result);

    void getWeeklyStatsResult(const QList<float>& totalMinutes, const QList<int>& totalMistakes);
    void getMonthStatsResult(const QList<float>& totalMinutes, const QList<int>& totalMistakes);

    void signResult(const QString& sessionKeyOrMessage);



    void renameApiDbFileResult(const QString& result);
    void changeApiDbFileVisiblityResult(const QString& result);
    void deleteApiDbFileResult(const QString& result);

private slots:
    void onUrlListReceived();
    void onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);
    void onDownloadFinished(bool success, const QString &filePath);
    void onUploadFinished(bool success, const QString& result);
    void onSignResult();



    void onRenameApiDbFile();
    void onChangeApiDbFileVisiblity();
    void onDeleteApiDbFile();
};

#endif // BACKEND_H
