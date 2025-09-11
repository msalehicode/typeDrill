#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "./include/backend.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QCoreApplication::setOrganizationName("orgTypeDrill");
    QCoreApplication::setApplicationName("appTypeDrill");

    QQmlApplicationEngine engine;

    // Add the import path for QML resources (this may fix missing resource issues)
    engine.addImportPath(QGuiApplication::applicationDirPath() + "/qml");


    // Enable QML debugging
    qputenv("QML_IMPORT_TRACE", "1");

    // Create backend instance
    Backend backend;
    engine.rootContext()->setContextProperty("backend", &backend);

    const QUrl url(QStringLiteral("qrc:/TypeDrill/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
