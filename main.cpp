#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QQmlContext>
#include <QTimer>
#include <QImage>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("HomeAuto"));
    app.setOrganizationName(QStringLiteral("HomeAuto"));

    // Basic style is fully customizable (lets our Theme drive everything).
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QQmlApplicationEngine engine;

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // Verification helper: start on a chosen tab (0 lights, 1 watering, 2 climate).
    engine.rootContext()->setContextProperty(
        QStringLiteral("startTab"),
        qEnvironmentVariableIntValue("HOMEAUTO_TAB"));

    engine.load(QUrl(QStringLiteral("qrc:/HomeAuto/qml/Main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    // Optional offscreen screenshot for verification: HOMEAUTO_SHOT=/path.png
    if (qEnvironmentVariableIsSet("HOMEAUTO_SHOT")) {
        const QString path = qEnvironmentVariable("HOMEAUTO_SHOT");
        auto *win = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
        QTimer::singleShot(1800, win, [win, path]() {
            if (win) {
                QImage img = win->grabWindow();
                img.save(path);
            }
            QCoreApplication::quit();
        });
    }

    return app.exec();
}
