#include "../include/database.h"

DataBase::DataBase(QObject *parent)
    : QObject{parent}
{

}

DataBase::~DataBase()
{
    m_db.close();
}

bool DataBase::init(const QString &path, const QString &fileName)
{
    //for swiching database case, need to make sure close previues connection
    const QString connectionName = "qt_sql_default_connection";

    // Close and remove old connection safely
    if (QSqlDatabase::contains(connectionName))
    {
        // Get the connection
        QSqlDatabase oldDb = QSqlDatabase::database(connectionName);
        if (oldDb.isOpen())
            oldDb.close();

        // Important: clear all queries/models here that might hold the connection

        // Remove the connection - but only when no references remain!
        QSqlDatabase::removeDatabase(connectionName);


        // Now m_db should be reset too (no longer refer to the removed connection)
        m_db = QSqlDatabase();
    }


    bool result=false;
    m_db = QSqlDatabase::addDatabase("QSQLITE", connectionName);


    QString fullPath = path+"/"+fileName;
    m_db.setDatabaseName(fullPath);
    bool fileExistedBefore = QFile::exists(fullPath);

    if(fileExistedBefore)
    {
        // qInfo() << "databae exists, we will trying to open it.";
        if(m_db.open())
        {
            qInfo() << "Database file opened.";
            result=true;
        }
    }
    else
    {
        QDir dbDire(path);
        if (!dbDire.exists())
            dbDire.mkpath(".");

        if(m_db.open())
        {
            qInfo() << "an empty database file created.";
            result=true;
        }
        else
        {
            qInfo() << "error: could not create database file.";
            result=false;
        }
    }
    return result;
}

bool DataBase::isOpen()
{
    return m_db.open();
}

QSqlDatabase DataBase::getDatabase() const
{
    return m_db;
}

// Create a table with a given schema (columns and types)
bool DataBase::createTable(const QString& tableName, const QString& schema)
{
    if (!m_db.isOpen()) return false;

    QSqlQuery query(m_db);
    QString sql = QString("CREATE TABLE IF NOT EXISTS %1 (%2);").arg(tableName, schema);

    if(!query.exec(sql))
    {
        // qWarning() << "Create table failed:" << query.lastError().text();
        return false;
    }
    return true;
}

// Remove (drop) a table
bool DataBase::removeTable(const QString& tableName)
{
    if (!m_db.isOpen()) return false;

    QSqlQuery query(m_db);
    QString sql = QString("DROP TABLE IF EXISTS %1;").arg(tableName);

    if(!query.exec(sql))
    {
        // qWarning() << "Remove table failed:" << query.lastError().text();
        return false;
    }
    return true;
}

// Insert into table - data map keys are column names, values are column values
bool DataBase::insertIntoTable(const QString& tableName, const QMap<QString, QVariant>& data)
{
    if (!m_db.isOpen()) return false;
    if (data.isEmpty()) return false;

    QStringList columns = data.keys();
    QStringList placeholders;
    for (const auto& col : columns)
        placeholders << ":" + col;

    QString sql = QString("INSERT INTO %1 (%2) VALUES (%3);")
                      .arg(tableName)
                      .arg(columns.join(", "))
                      .arg(placeholders.join(", "));

    QSqlQuery query(m_db);
    query.prepare(sql);

    for (auto it = data.constBegin(); it != data.constEnd(); ++it)
        query.bindValue(":" + it.key(), it.value());

    if (!query.exec())
    {
        // qWarning() << "Insert failed:" << query.lastError().text();
        return false;
    }
    return true;
}

// Update value in table - update one column for a row identified by keyColumn = keyValue
bool DataBase::updateTableValue(const QString& tableName, const QString& keyColumn, const QVariant& keyValue,
                                const QString& updateColumn, const QVariant& updateValue)
{
    if (!m_db.isOpen()) return false;

    QString sql = QString("UPDATE %1 SET %2 = :updateVal WHERE %3 = :keyVal;")
                      .arg(tableName, updateColumn, keyColumn);

    QSqlQuery query(m_db);
    query.prepare(sql);

    query.bindValue(":updateVal", updateValue);
    query.bindValue(":keyVal", keyValue);

    if (!query.exec())
    {
        // qWarning() << "Update failed:" << query.lastError().text();
        return false;
    }
    return true;
}

bool DataBase::updateTableRow(const QString& tableName,
                              const QString& keyColumn,
                              const QVariant& keyValue,
                              const QMap<QString, QVariant>& updateValues)
{
    if (!m_db.isOpen() || updateValues.isEmpty())
        return false;

    QStringList setClauses;
    QMap<QString, QVariant>::const_iterator it;

    for (it = updateValues.constBegin(); it != updateValues.constEnd(); ++it)
    {
        setClauses << QString("%1 = :%2").arg(it.key(), it.key()); // named bind keys
    }

    QString sql = QString("UPDATE %1 SET %2 WHERE %3 = :keyVal;")
                      .arg(tableName, setClauses.join(", "), keyColumn);

    QSqlQuery query(m_db);
    query.prepare(sql);

    // Bind all column values
    for (it = updateValues.constBegin(); it != updateValues.constEnd(); ++it)
    {
        query.bindValue(":" + it.key(), it.value());
    }

    // Bind the key
    query.bindValue(":keyVal", keyValue);

    if (!query.exec())
    {
        qWarning() << "Update failed:" << query.lastError().text();
        return false;
    }

    return true;
}


// Search table where columnName matches searchValue, returns list of maps with column-value pairs
QList<QMap<QString, QVariant>> DataBase::searchTable(const QString& tableName, const QString& columnName,
                                                     const QVariant& searchValue)
{
    QList<QMap<QString, QVariant>> results;
    if (!m_db.isOpen()) return results;

    QString sql = QString("SELECT * FROM %1 WHERE %2 = :searchVal;").arg(tableName, columnName);

    QSqlQuery query(m_db);
    query.prepare(sql);
    query.bindValue(":searchVal", searchValue);

    if (!query.exec())
    {
        // qWarning() << "Search failed:" << query.lastError().text();
        return results;
    }

    while (query.next())
    {
        QMap<QString, QVariant> row;
        QSqlRecord record = query.record();
        for (int i = 0; i < record.count(); ++i)
        {
            row.insert(record.fieldName(i), query.value(i));
        }
        results.append(row);
    }
    return results;
}

QString DataBase::searchTable(const QString &tableName, const QString &columnName,
                              const QString &searchValue, const QString &columnYouWant)
{
    auto results = searchTable(tableName, columnName, searchValue);
    for (const auto& row : results)
    {
        return row.value(columnYouWant).toString();
    }
    return "";
}


QVariantList DataBase::getAllRowsAsVariantList(const QString& tableName)
{
    QVariantList resultList;

    QString sql = QString("SELECT * FROM %1;").arg(tableName);

    QSqlQuery query(m_db);
    if (!query.exec(sql))
    {
        // qWarning() << "Failed to get all rows:" << query.lastError().text();
    }

    while (query.next())
    {
        QVariantMap rowMap;
        QSqlRecord record = query.record();
        for (int i = 0; i < record.count(); ++i)
        {
            rowMap.insert(record.fieldName(i), query.value(i));
        }
        resultList.append(rowMap);
    }

    return resultList;
}

int DataBase::countRows(const QString& tableName)
{
    if (!m_db.isOpen()) {
        // qWarning() << "Database is not open!";
        return -1;  // or 0, or some error code
    }

    QSqlQuery query(m_db);
    QString sql = QString("SELECT COUNT(*) FROM %1").arg(tableName);

    if (!query.exec(sql)) {
        // qWarning() << "Count query failed:" << query.lastError().text();
        return -1;
    }

    if (query.next()) {
        return query.value(0).toInt();
    }

    return 0;
}

QVariant DataBase::runQuery(const QString &tableName, const QVariantMap &params, const QVariantMap &where, const QString &returnColumn)
{
    QString rawQuery = tableName;  // overload: `tableName` used to pass raw SQL
    QSqlQuery query(m_db);

    if (!query.prepare(rawQuery)) {
        qWarning() << "Failed to prepare custom query:" << query.lastError().text();
        return QVariant();
    }

    // Bind values
    for (auto it = params.begin(); it != params.end(); ++it) {
        query.bindValue(":" + it.key(), it.value());
    }

    if (!query.exec()) {
        qWarning() << "Failed to execute custom query:" << query.lastError().text();
        return QVariant();
    }

    // Expecting a single row, single column (e.g., COUNT(*))
    if (query.next()) {
        return query.value(0);
    } else {
        return QVariant();
    }
}


