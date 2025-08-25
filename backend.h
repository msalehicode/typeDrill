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


class Backend : public QObject
{
    Q_OBJECT
    DataBase m_db;
    QString currentTableName;
    QString currentTableType;
    QString databaseFullPath;

    int currentStreakCount;
    QDate lastPracticeDate;

    void wordIs();
    bool init();
    QString m_api_url;
    QString m_api_key;
    QString m_dbPath;
    SettingsManager settings;


    QNetworkAccessManager m_networkManager;
    FileManager m_fileManager;



public:
    explicit Backend(QObject *parent = nullptr);
    Q_INVOKABLE int getNextWord(const QString& userText); // Call from QML
    Q_INVOKABLE void setPracticeResult(const QString& mistakeCount, const QString& timeSpent);
    Q_INVOKABLE void getTables(const QString& tableType); // Call from QML
    Q_INVOKABLE void createTable(const QString& tableName, const QString& tableType); // Call from QML
    Q_INVOKABLE void switchTable(const QString& tableName, const QString& ttype); // Call from QML
    Q_INVOKABLE void whatIsCurrentTableType(); // Call from QML
    Q_INVOKABLE void addWordToTable(const QStringList& data); // Call from QML
    Q_INVOKABLE void resetPractice(); // Call from QML
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

    Q_INVOKABLE QStringList getStreakDays();
    int calculateStreakDays();
    QDate getLastActivityDate();

    QSqlQuery* m_query;
    int min_id;
    int max_id;
    int last_id;
    QStringList last_word;

signals:
    void wordReady(const QStringList& word);  // Emit to QML
    void wordIsIncorrect(const QString& correctStatus);
    void tablesList(const QVariantList& tableList);  // Emit to QML
    void tableCreationResult(const QString& tableCreationResult);
    void tableTypeIs(const QString& currentTableType);
    void addItemtoTableResult(const QString& result);


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
