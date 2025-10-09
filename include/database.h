#ifndef DATABASE_H
#define DATABASE_H

#include <QObject>

//SQL include
#include <QtSql/QSql>
#include <QtSql/QSqlDatabase>
#include <QtSql/QSqlQuery>
#include <QSqlError>

//include File and Directory option
#include <QFile>
#include <QDir>

#include <QDebug>


#include <QVariant>
#include <QMap>
#include <QList>
#include <QSqlRecord>

class DataBase : public QObject
{
    Q_OBJECT

    QSqlDatabase m_db;

    bool isDbExists(const QString& path, const QString& fileName);

public:
    explicit DataBase(QObject *parent = nullptr);
    ~DataBase();
    bool init(const QString& path, const QString& fileName);
    bool isOpen();
    QSqlDatabase getDatabase() const;
    bool createTable(const QString& tableName, const QString& schema);
    bool removeTable(const QString& tableName);
    bool renameTable(const QString& tableName,const QString& newName);

    bool insertIntoTable(const QString& tableName, const QMap<QString, QVariant>& data);
    bool updateTableValue(const QString& tableName, const QString& keyColumn, const QVariant& keyValue,
                          const QString& updateColumn, const QVariant& updateValue);

    bool updateTableRow(const QString& tableName,
                        const QString& keyColumn,
                        const QVariant& keyValue,
                        const QMap<QString, QVariant>& updateValues);

    QList<QMap<QString, QVariant>> searchTable(const QString& tableName,
                                               const QString& columnName,
                                               const QVariant& searchValue);
    QString searchTable(const QString& tableName,
                        const QString& columnName,
                        const QString& searchValue,
                        const QString& columnYouWant);
    QVariantList getAllRowsAsVariantList(const QString& tableName);

    int countRows(const QString& tableName);
    int countRowsWhere(const QString& tableName, const QString& key, const QString& value);

    bool removeRow(const QString& tableName, const QString& rowKey, const QString& rowValue);

    QVariant runQuery(const QString& tableName,
                      const QVariantMap& params = {},
                      const QVariantMap& where = {},
                      const QString& returnColumn = QString());

    QVariantList runQueryGetVariantList(const QString &rawQuery, const QVariantMap &params);
signals:
};
#endif // DATABASE_H
