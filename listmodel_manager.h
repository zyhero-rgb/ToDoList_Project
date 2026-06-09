#ifndef LISTMODEL_MANAGER_H
#define LISTMODEL_MANAGER_H

#include <QObject>
#include <QFile>
#include <QStandardPaths>
#include <QTextStream>
#include <QDir>
#include <QString>
#include <QDebug>
#include <QVariantList>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonParseError>

class ListModel_Manager : public QObject
{
    Q_OBJECT
public:
    ListModel_Manager(QObject *parent = nullptr);

    // 任务数据
    Q_INVOKABLE void saveData(const QVariantList &tasks);
    Q_INVOKABLE QVariantList loadData();

    // 用户设置（主题颜色、字体大小）
    Q_INVOKABLE void saveSettings(const QString &accentColor, int fontSize);
    Q_INVOKABLE QVariantMap loadSettings();

private:
    QString m_DataPath;
    QString m_SettingsPath;
};

#endif // LISTMODEL_MANAGER_H