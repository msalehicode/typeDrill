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

bool DataBase::renameTable(const QString &tableName, const QString &newName)
{
    if (!m_db.isOpen()) return false;

    QSqlQuery query(m_db);
    QString sql = QString("ALTER TABLE %1 RENAME TO %2;").arg(tableName).arg(newName);

    if(!query.exec(sql))
    {
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

bool DataBase::updateTableAllRows(const QString &tableName, const QString &col, const QString &val)
{
    if (!m_db.isOpen()) return false;

    QString sql = QString("UPDATE %1 SET %2 = :updateVal;")
                      .arg(tableName, col);

    QSqlQuery query(m_db);
    query.prepare(sql);

    query.bindValue(":updateVal", val);

    if (!query.exec())
    {
        // qWarning() << "Update failed:" << query.lastError().text();
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
        qInfo() << "Database is not open!";
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

int DataBase::countRowsWhere(const QString &tableName, const QString &key, const QString &value)
{
    if (!m_db.isOpen()) {
        qInfo() << "Database is not open!";
        return -1;
    }

    QSqlQuery query(m_db);

    // Construct the query with placeholders
    QString sql = QString("SELECT COUNT(*) FROM %1 WHERE %2 = :value")
                      .arg(tableName, key);
    query.prepare(sql);
    query.bindValue(":value", value);

    if (!query.exec()) {
        qWarning() << "Count query failed:" << query.lastError().text();
        return -1;
    }

    if (query.next()) {
        return query.value(0).toInt();
    }

    return 0;
}


bool DataBase::removeRow(const QString &tableName, const QString &rowKey, const QString &rowValue)
{
    QSqlQuery query(m_db);
    QString sql = QString("DELETE FROM %1 WHERE %2 = :value").arg(tableName).arg(rowKey);

    query.prepare(sql);
    query.bindValue(":value", rowValue);

    if (!query.exec())
    {
        qWarning() << "Delete query failed:" << query.lastError().text();
        return false;
    }

    return true;
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

QVariantList DataBase::runQueryGetVariantList(const QString &rawQuery, const QVariantMap &params)
{
    QSqlQuery query(m_db);

    // Prepare the query
    if (!query.prepare(rawQuery)) {
        qWarning() << "Failed to prepare custom query:" << query.lastError().text();
        return QVariantList();  // Return an empty list if preparation fails
    }

    // Bind the parameters
    for (auto it = params.begin(); it != params.end(); ++it) {
        query.bindValue(":" + it.key(), it.value());
    }

    // Execute the query
    if (!query.exec()) {
        qWarning() << "Failed to execute custom query:" << query.lastError().text();
        return QVariantList();  // Return an empty list if execution fails
    }

    QVariantList results;  // List to store the results

    // Iterate through the result set
    while (query.next()) {
        QVariantMap row;  // Map to store each row of data
        for (int i = 0; i < query.record().count(); ++i) {
            row[query.record().fieldName(i)] = query.value(i);  // Add each column to the map
        }
        results.append(row);  // Add the row map to the results list
    }

    return results;  // Return the populated QVariantList
}



