#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "listmodel_manager.h"

int main(int argc, char *argv[])
{
    // 强制使用 Basic 样式（解决控件自定义警告，必须在 QGuiApplication 之前设置）
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");

    QGuiApplication app(argc, argv);

    // 设置组织信息（解决 Settings 初始化警告）
    app.setOrganizationName("ToDoList");
    app.setOrganizationDomain("todolist.app");
    app.setApplicationName("极简待办");

    QQmlApplicationEngine engine;

    // 创建ListModel_Manager实例并注册到QML
    ListModel_Manager *listModelManager = new ListModel_Manager(&engine);
    engine.rootContext()->setContextProperty("listModelManager", listModelManager);

    const QUrl url(QStringLiteral("qrc:/ToDoList_Project/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl)
        {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return QCoreApplication::exec();
}
