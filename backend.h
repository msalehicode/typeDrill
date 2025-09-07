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


class Backend : public QObject
{
    Q_OBJECT
    DataBase m_db;
    QString currentTableName;
    QString currentTableType;
    QString databaseFullPath;

    int currentStreakCount;
    QDate lastPracticeDate;


    bool init(QString databaseName="");
    QString m_api_url;
    QString m_api_key;
    QString m_dbPath;
    SettingsManager settings;


    QNetworkAccessManager m_networkManager;
    FileManager m_fileManager;



public:
    explicit Backend(QObject *parent = nullptr);
    Q_INVOKABLE int getNextWord(const QString& userText, const bool& isModified=false);
    Q_INVOKABLE void setPracticeResult(const QString& mistakeCount, const QString& timeSpent, const int& practiceType);
    Q_INVOKABLE void getTables(const QString& searchedTitle, const QString& tableType);
    Q_INVOKABLE QString pinTable(const QString& tableId);
    Q_INVOKABLE void createTable(const QString& tableName, const QString& tableType);
    Q_INVOKABLE void switchTable(const QString& tableName, const QString& ttype);
    Q_INVOKABLE void createDatabase(const QString& databaseName);
    Q_INVOKABLE void removeDatabase(const QString& databaseName);
    Q_INVOKABLE void whatIsCurrentTableType();
    Q_INVOKABLE void addWordToTable(const QStringList& data);
    Q_INVOKABLE void modifyWordOnTable(const int& targetWordId, const QString& tagetTableType, const QStringList& data);
    Q_INVOKABLE void resetPractice();
    Q_INVOKABLE QString databasePath();
    Q_INVOKABLE QStringList listOfDatabases();
    Q_INVOKABLE QString switchDatabase(const QString& databaseName);
    Q_INVOKABLE QString whatIsCurrentDatabase();
    Q_INVOKABLE QString getApiUrl();
    Q_INVOKABLE QString getApiKey();
    Q_INVOKABLE void setApiUrl(const QString& apiURL);
    Q_INVOKABLE void setApiKey(const QString& apiKey);

    Q_INVOKABLE void fetchUrlList();
    Q_INVOKABLE void download(const QString &url, const QString &fileName);
    Q_INVOKABLE void uploadFileToApi(const QString& fileName, const QString& publicStatus);

    Q_INVOKABLE QString getThemeMode();
    Q_INVOKABLE void setThemeMode(const QString& themeTitle);

    Q_INVOKABLE QStringList getStreakDays();
    int calculateStreakDays(QDate& currentDate);
    QDate getLastActivityDate();
    bool removeFile(const QString& filepath);

    Q_INVOKABLE int getLastWindowSize(const QString& widthOrHeight);
    Q_INVOKABLE void setLastWindowSize(const QString& wOrh , const int &value);


    QSqlQuery* m_query;
    int min_id;
    int max_id;
    int last_id;
    QList<QMap<QString, QVariant>> current_word;

signals:
    void wordReady(const QList<QMap<QString, QVariant>>& word);  // Emit to QML
    void practiceFinished();
    void wordIsIncorrect(const QString& correctStatus);
    void tablesList(const QVariantList& tableList);  // Emit to QML
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

private slots:
    void onUrlListReceived();
    void onDownloadProgress(qint64 bytesReceived, qint64 bytesTotal);
    void onDownloadFinished(bool success, const QString &filePath);
    void onUploadFinished(bool success, const QString& result);
};

#endif // BACKEND_H
