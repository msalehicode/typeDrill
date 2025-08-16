#ifndef BACKEND_H
#define BACKEND_H

#include <QObject>
#include <QStandardPaths>

#include "database.h"
#include "settingsmanager.h"

class Backend : public QObject
{
    Q_OBJECT
    DataBase m_db;
    QString currentTableName;
    QString currentTableType;
    QString databaseFullPath;
    void wordIs();
    bool init();
    SettingsManager settings;

public:
    explicit Backend(QObject *parent = nullptr);
    Q_INVOKABLE int getNextWord(const QString& userText); // Call from QML
    Q_INVOKABLE void getTables(const QString& tableType); // Call from QML
    Q_INVOKABLE void createTable(const QString& tableName, const QString& tableType); // Call from QML
    Q_INVOKABLE void switchTable(const QString& tableName, const QString& ttype); // Call from QML
    Q_INVOKABLE void whatIsCurrentTableType(); // Call from QML
    Q_INVOKABLE void addWordToTable(const QStringList& data); // Call from QML
    Q_INVOKABLE void resetPractice(); // Call from QML
    Q_INVOKABLE QString databasePath();
    Q_INVOKABLE QStringList listOfDatabases();
    Q_INVOKABLE QString switchDatabase(const QString& databaseName);

    QSqlQuery* m_query;
    // QString m_queryStr;
    int min_id;
    int max_id;
    int last_id;
    QStringList last_word;

signals:
    void wordReady(const QStringList& word);  // Emit to QML
    void tablesList(const QVariantList& tableList);  // Emit to QML
    void tableCreationResult(const QString& tableCreationResult);
    void tableTypeIs(const QString& currentTableType);
    void addItemtoTableResult(const QString& result);
};

#endif // BACKEND_H
