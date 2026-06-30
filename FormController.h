/*
* KeyVaultLite
 * https://github.com/cartel-developer/keyvault-lite
 *
 * File: FormController.h
 * Description: Handles SQLite key-value storage and queries
 *
 * Author: Mohammad Amin Mardani
 * License: MIT
 */

#pragma once
#include <QObject>
#include <QVariantList>

class QSqlDatabase;

class FormController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(QVariantList items READ items NOTIFY itemsChanged)

public:
    explicit FormController(QObject *parent = nullptr);

    QString statusMessage() const;
    QVariantList items() const;

public slots:
    void submitForm(const QString &key, const QString &value);
    void clearForm();
    Q_INVOKABLE void loadItems();
    Q_INVOKABLE bool deleteEntry(int id);
    Q_INVOKABLE bool updateEntry(int id, const QString &key, const QString &value);

signals:
    void statusMessageChanged();
    void formCleared();
    void itemsChanged();

private:
    void initDatabase();
    bool savePairToDatabase(const QString &key, const QString &value);
    void setStatusMessage(const QString &message);

    QString m_statusMessage;
    QVariantList m_items;
};
