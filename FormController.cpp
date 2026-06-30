/*
* KeyVaultLite
 * https://github.com/cartel-developer/keyvault-lite
 *
 * File: FormController.cpp
 * Description: Handles SQLite key-value storage and queries
 *
 * Author: Mohammad Amin Mardani
 * License: MIT
 */

#include "FormController.h"
#include <QDebug>
#include <QDir>
#include <QSqlDatabase>
#include <QSqlError>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QVariantMap>

FormController::FormController(QObject *parent)
    : QObject(parent)
    , m_statusMessage(QStringLiteral("Form is ready."))
{
    initDatabase();
    loadItems();
}

QString FormController::statusMessage() const
{
    return m_statusMessage;
}

QVariantList FormController::items() const
{
    return m_items;
}

void FormController::submitForm(const QString &key, const QString &value)
{
    const QString trimmedKey = key.trimmed();
    const QString trimmedValue = value.trimmed();

    if (trimmedKey.isEmpty() || trimmedValue.isEmpty()) {
        setStatusMessage(QStringLiteral("Please enter both key and value."));
        return;
    }

    if (!savePairToDatabase(trimmedKey, trimmedValue)) {
        setStatusMessage(QStringLiteral("Failed to save data to database."));
        return;
    }

    setStatusMessage(QStringLiteral("Data saved to database: %1 = %2").arg(trimmedKey, trimmedValue));
    loadItems();
}

void FormController::clearForm()
{
    setStatusMessage(QStringLiteral("Form cleared."));
    emit formCleared();
}

void FormController::loadItems()
{
    QSqlDatabase db = QSqlDatabase::database();
    if (!db.isOpen()) {
        setStatusMessage(QStringLiteral("Database is not available."));
        return;
    }

    QSqlQuery query(db);
    if (!query.exec(QStringLiteral("SELECT id, key, value FROM kv_pairs ORDER BY id DESC"))) {
        setStatusMessage(QStringLiteral("Failed to load stored items."));
        return;
    }

    QVariantList result;
    while (query.next()) {
        QVariantMap row;
        row.insert("id", query.value("id").toInt());
        row.insert("key", query.value("key").toString());
        row.insert("value", query.value("value").toString());
        result.append(row);
    }

    if (result == m_items) {
        return;
    }

    m_items = result;
    emit itemsChanged();
}

bool FormController::deleteEntry(int id)
{
    QSqlDatabase db = QSqlDatabase::database();
    if (!db.isOpen()) {
        setStatusMessage(QStringLiteral("Database is not available."));
        return false;
    }

    QSqlQuery query(db);
    query.prepare(QStringLiteral("DELETE FROM kv_pairs WHERE id = :id"));
    query.bindValue(QStringLiteral(":id"), QVariant(id));

    if (!query.exec()) {
        setStatusMessage(QStringLiteral("Failed to delete selected row."));
        return false;
    }

    setStatusMessage(QStringLiteral("Row deleted successfully."));
    loadItems();
    return true;
}

bool FormController::updateEntry(int id, const QString &key, const QString &value)
{
    const QString trimmedKey = key.trimmed();
    const QString trimmedValue = value.trimmed();

    if (trimmedKey.isEmpty() || trimmedValue.isEmpty()) {
        setStatusMessage(QStringLiteral("Please enter both key and value."));
        return false;
    }

    if (id <= 0) {
        setStatusMessage(QStringLiteral("Invalid item selected."));
        return false;
    }

    QSqlDatabase db = QSqlDatabase::database();
    if (!db.isOpen()) {
        setStatusMessage(QStringLiteral("Database is not available."));
        return false;
    }

    QSqlQuery query(db);
    query.prepare(QStringLiteral("UPDATE kv_pairs SET key = :key, value = :value WHERE id = :id"));
    query.bindValue(QStringLiteral(":key"), QVariant(trimmedKey));
    query.bindValue(QStringLiteral(":value"), QVariant(trimmedValue));
    query.bindValue(QStringLiteral(":id"), QVariant(id));

    if (!query.exec()) {
        setStatusMessage(QStringLiteral("Failed to update selected row."));
        return false;
    }

    if (query.numRowsAffected() == 0) {
        setStatusMessage(QStringLiteral("No row was updated."));
        return false;
    }

    setStatusMessage(QStringLiteral("Row updated successfully."));
    loadItems();
    return true;
}

void FormController::initDatabase()
{
    const QString dbPath = QDir::currentPath() + QStringLiteral("/kv_store.db");
    QSqlDatabase db = QSqlDatabase::addDatabase(QStringLiteral("QSQLITE"));
    db.setDatabaseName(dbPath);

    if (!db.open()) {
        setStatusMessage(QStringLiteral("Could not open database."));
        return;
    }

    QSqlQuery query(db);
    const char *createTableSql =
            "CREATE TABLE IF NOT EXISTS kv_pairs ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "key TEXT NOT NULL, "
            "value TEXT NOT NULL, "
            "created_at TEXT DEFAULT CURRENT_TIMESTAMP"
            ")";

    if (!query.exec(QLatin1String(createTableSql))) {
        setStatusMessage(QStringLiteral("Database is open, but table creation failed."));
        return;
    }
}

bool FormController::savePairToDatabase(const QString &key, const QString &value)
{
    QSqlDatabase db = QSqlDatabase::database();
    if (!db.isOpen()) {
        return false;
    }

    QSqlQuery query(db);
    query.prepare(QStringLiteral("INSERT INTO kv_pairs(key, value) VALUES(:key, :value)"));
    query.bindValue(QStringLiteral(":key"), QVariant(key));
    query.bindValue(QStringLiteral(":value"), QVariant(value));

    if (!query.exec()) {
        qWarning() << "SQLite insert failed:" << query.lastError().text();
        return false;
    }

    return true;
}

void FormController::setStatusMessage(const QString &message)
{
    if (m_statusMessage == message) {
        return;
    }

    m_statusMessage = message;
    emit statusMessageChanged();
}
