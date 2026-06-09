#include "listmodel_manager.h"

ListModel_Manager::ListModel_Manager(QObject *parent) : QObject(parent)
{
    // 在Windows上返回：C:/Users/用户名/Documents
    QString docPath = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation);

    m_DataPath = QDir(docPath).filePath("Data.json");
    m_SettingsPath = QDir(docPath).filePath("Settings.json");

    // 确保目录存在
    QDir dir = QFileInfo(m_DataPath).dir();
    if (!dir.exists())
    {
        dir.mkpath(".");
    }
    qDebug() << "users' data are contained in " << m_DataPath << '\n';
    qDebug() << "settings are contained in " << m_SettingsPath << '\n';
}

// QVariant 是Qt中的一个通用类型容器，可以存储几乎所有Qt支持的数据类型
// 保存数据
void ListModel_Manager::saveData(const QVariantList &tasks)
{
    // 打开文件
    QFile file(m_DataPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        qDebug() << "无法打开文件进行写入:" << file.errorString();
        return;
    }

    // 创建Json数组
    QJsonArray jsonArray;

    QTextStream out(&file);
    for (const QVariant &task : tasks)
    {
        // 转换为Map，键值对
        QVariantMap taskMap = task.toMap();

        // 创建Json对象
        QJsonObject jsonObject;

        jsonObject["task"] = taskMap.value("task").toString();
        jsonObject["completed"] = taskMap.value("completed").toBool();
        jsonArray.append(jsonObject);
    }

    QJsonDocument doc(jsonArray);
    file.write(doc.toJson());

    file.close();
    qDebug() << "Json文件保存成功，保存了" << tasks.size() << "个";
}

// 加载数据
QVariantList ListModel_Manager::loadData()
{
    QVariantList tasks;

    // 打开Json文件
    QFile file(m_DataPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qDebug() << "无法打开文件进行读取:" << file.errorString();
        return tasks;
    }
    //  读取文件内容
    QByteArray data = file.readAll();
    file.close();
    // 解析Json文件
    QJsonParseError parseerror;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseerror);
    if (parseerror.error != QJsonParseError::NoError)
    {
        qDebug() << "Json文件解析错误" << "\n";
        return tasks;
    }

    if (doc.isArray()) // 检查根元素是否是数组
    {
        QJsonArray jsonArray = doc.array();
        for (const QJsonValue &value : jsonArray)
        {
            QJsonObject obj = value.toObject();

            QVariantMap map;
            map["task"] = obj.value("task").toString();
            map["completed"] = obj.value("completed").toBool();

            tasks.append(map);
        }
    }
    else
    {
        qDebug() << "JSON格式错误：顶层不是数组";
    }
    qDebug() << "加载数据成功" << '\n';
    return tasks;
}

// 保存用户设置（主题颜色，字体大小）
void ListModel_Manager::saveSettings(const QString &accentColor, int fontSize)
{
    QFile file(m_SettingsPath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        qDebug() << "无法打开设置文件进行写入:" << file.errorString();
        return;
    }

    QJsonObject settingsObj;
    settingsObj["accentColor"] = accentColor;
    settingsObj["fontSize"] = fontSize;

    QJsonDocument doc(settingsObj);
    file.write(doc.toJson());
    file.close();

    qDebug() << "设置保存成功: 颜色 =" << accentColor << ", 字体大小 =" << fontSize;
}

// 加载用户设置
QVariantMap ListModel_Manager::loadSettings()
{
    QVariantMap settings;
    settings["accentColor"] = "#4361ee"; // 默认值
    settings["fontSize"] = 16;

    QFile file(m_SettingsPath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        qDebug() << "设置文件不存在，使用默认设置";
        return settings;
    }

    QByteArray data = file.readAll();
    file.close();

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);
    if (parseError.error != QJsonParseError::NoError)
    {
        qDebug() << "设置文件解析错误:" << parseError.errorString();
        return settings;
    }

    if (doc.isObject())
    {
        QJsonObject obj = doc.object();
        if (obj.contains("accentColor"))
            settings["accentColor"] = obj.value("accentColor").toString();
        if (obj.contains("fontSize"))
            settings["fontSize"] = obj.value("fontSize").toInt();
    }

    qDebug() << "设置加载成功:" << settings["accentColor"].toString()
             << ", 字体大小:" << settings["fontSize"].toInt();
    return settings;
}