/*
* KeyVaultLite
 * https://github.com/cartel-developer/keyvault-lite
 *
 * File: main.cpp
 * Description: Handles SQLite key-value storage and queries
 *
 * Author: Mohammad Amin Mardani
 * License: MIT
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "FormController.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    FormController formController;

    engine.rootContext()->setContextProperty("formController", &formController);
    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return QGuiApplication::exec();
}
