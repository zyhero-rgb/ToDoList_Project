#ifndef LISTMODEL_MANAGER_H
#define LISTMODEL_MANAGER_H

#include <QObject>
#include <QSqlDatabase>

class ListModel_Manager : public QObject
{
    Q_OBJECT
public:
    ListModel_Manager(QObject *parent = nullptr);

    Q_INVOKABLE int addTask(QString task);                      // 添加
    Q_INVOKABLE bool updateTaskStatus(int id, bool completed);  // 更改任务的状态
    Q_INVOKABLE bool deleteTask(int id);                        // 删除任务

    Q_INVOKABLE QVariantList loadTasks();                       // 加载所有的任务
    Q_INVOKABLE void saveSetting(QString key, QString value);   // 保存设置
    Q_INVOKABLE QString loadSetting(QString key);               // 加载设置

private:
    bool initDatabase(QString path);

private:
    QSqlDatabase m_database;
};

#endif // LISTMODEL_MANAGER_H