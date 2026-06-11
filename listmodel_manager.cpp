#include "listmodel_manager.h"
#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QFileInfo>
#include <QSqlQuery>
#include <QSqlError>

ListModel_Manager::ListModel_Manager(QObject *parent)
{
    // 获取保存数据的路径
    QString str = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (!QDir().mkpath(str))
    {
        qDebug() << str << "does not exist";
    }
    // 构建数据库文件路径
    QString dataPath = QDir(str).filePath("tasks.db");
    if (!QFileInfo::exists(dataPath))
    {
        qDebug() << dataPath << "does not exist";
    }
    qInfo() << "dataPath : " << dataPath;
    initDatabase(dataPath);
}

// 初始化数据库
bool ListModel_Manager::initDatabase(QString path)
{
    m_database = QSqlDatabase::addDatabase("QSQLITE");
    m_database.setDatabaseName(path);

    if (!m_database.open())
    {
        qDebug() << "fail to open the database," << m_database.lastError().text();
        return false;
    }

    QSqlQuery query(m_database);
    // 建表
    query.exec(R"(
    CREATE TABLE IF NOT EXISTS tasks
        (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task TEXT NOT NULL,
            completed INTEGER DEFAULT 0,
            created_at TEXT DEFAULT (datetime('now','localtime'))
        )
        )");
    if (query.lastError().isValid())
    {
        qDebug() << "fail to create table tasks";
        return false;
    }

    query.exec(R"(
    CREATE TABLE IF NOT EXISTS settings
        (
            key TEXT PRIMARY KEY,
            value TEXT
        )
    )");
    if (query.lastError().isValid())
    {
        qDebug() << "fail to create table settings";
        return false;
    }

    qInfo() << "initDatabase successfully:" << path;
    return true;
}

// 添加任务
int ListModel_Manager::addTask(QString task)
{
    QSqlQuery q(m_database);
    q.prepare("INSERT INTO tasks (task) VALUES(:task)");
    q.bindValue(":task", task);
    if (!q.exec())
    {
        qDebug() << "Fail to insert a task";
        return -1;
    }
    qDebug() << "Insert a task successfully";
    return q.lastInsertId().toInt();
}

// 删除任务
bool ListModel_Manager::deleteTask(int id)
{
    QSqlQuery q(m_database);
    q.prepare("DELETE FROM tasks WHERE id = :id");
    q.bindValue(":id", id);
    if (!q.exec())
    {
        qDebug() << "Fail to delete task of " << id;
        return false;
    }
    qDebug() << "Delete task of " << id << "sucessfully";
    return true;
}

// 从数据库加载数据
QVariantList ListModel_Manager::loadTasks()
{
    QVariantList tasks;
    QSqlQuery q(m_database);
    q.exec("SELECT id, task, completed FROM tasks");
    while (q.next())
    {
        QVariantMap map;
        map["id"] = q.value(0).toInt();
        map["task"] = q.value(1).toString();
        map["completed"] = q.value(2).toBool();
        tasks.append(map);
    }
    qDebug() << "Load tasks sucessfully";
    return tasks;
}

// 更改任务的完成状态
bool ListModel_Manager::updateTaskStatus(int id, bool completed)
{
    QSqlQuery q(m_database);
    q.prepare("UPDATE tasks SET completed = :completed WHERE id = :id");
    q.bindValue(":completed", completed ? 1 : 0);
    q.bindValue(":id", id);
    if (!q.exec())
    {
        qDebug() << "Fail to update task status ,id = " << id;
        return false;
    }
    return true;
}

//保存设置
void ListModel_Manager::saveSetting(QString key, QString value)
{
    QSqlQuery q(m_database);
    q.prepare("INSERT OR REPLACE INTO settings (key,value) VALUES(:key, :value)");
    q.bindValue(":key", key);
    q.bindValue(":value", value);
    if (!q.exec())
    {
        qDebug() << "Fail to insert setting";
    }
}


// 加载设置
QString ListModel_Manager::loadSetting(QString key)
{
    QSqlQuery q(m_database);
    q.prepare("SELECT value FROM settings WHERE key = :key");
    q.bindValue(":key", key);
    if (q.exec() && q.next())
    {
        return q.value(0).toString();
    }
    return "";
}
