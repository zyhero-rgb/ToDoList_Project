import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt5Compat.GraphicalEffects
import QtCore
import "./Src/appBar"
import "./Src/bottomBar"
import "./Src/progressSection"
import "./Src/taskInputPanel"
import "./Src/taskItem"
import "./Src/taskListview"


Window {
    id: root
    width: 400
    height: 700
    minimumWidth: 350
    minimumHeight: 600
    maximumHeight: 750
    maximumWidth: 450
    visible: true
    title: qsTr("极简待办")
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.Window

    // 全局设置
    Settings {
        id: appSettings
        category: "Appearance"
        property string theme: "light"
        property string accentColor: "#4361ee"
        property int fontSize: 16
        property string backgroundImage: ""
    }

    // 颜色主题系统
    property color backgroundColor: {
        if(appSettings.theme === "dark") return "#1a1a2e"
        else if(appSettings.theme === "darkBlue") return "#16213e"
        else return "#f8f9fa"
    }

    property color surfaceColor: {
        if(appSettings.theme === "dark") return "#16213e"
        else if(appSettings.theme === "darkBlue") return "#0f3460"
        else return "#ffffff"
    }
    // 主题颜色
    property color primaryColor: appSettings.accentColor

    property color textColor: {
        if(appSettings.theme === "dark" || appSettings.theme === "darkBlue") return "#e6e6e6"
        else return "#2d3436"
    }

    property color secondaryTextColor: {
        if(appSettings.theme === "dark" || appSettings.theme === "darkBlue") return "#b2bec3"
        else return "#636e72"
    }

    property color borderColor: {
        if(appSettings.theme === "dark") return "#2d4059"
        else if(appSettings.theme === "darkBlue") return "#1a5f7a"
        else return "#dfe6e9"
    }

    // 数据管理
    Component.onCompleted: {
        var Color = listModelManager.loadSetting("accentColor")
        if(Color !== ""){
            appSettings.accentColor = Color;
        }
        var FontSize = listModelManager.loadSetting("fontSize")
        if(FontSize !== ""){
            appSettings.fontSize = parseInt(FontSize)
        }
        //程序启动时，加载任务数据
        var savedTasks = listModelManager.loadTasks()
        for (var i = 0; i < savedTasks.length; i++) {
            listmodel.append(savedTasks[i])
        }
    }

    Connections {
        target: appSettings
        function onAccentColorChanged() {
            listModelManager.saveSetting("accentColor", appSettings.accentColor)
        }
        function onFontSizeChanged() {
            listModelManager.saveSetting("fontSize", appSettings.fontSize)
        }
    }

    // 全局状态
    property bool isAdding: false

    // 主题切换函数
    function toggleTheme() {
        appSettings.theme = appSettings.theme === "light" ? "dark" : "light"
    }

    // 数据模型
    ListModel { id: listmodel }

    // 圆角背景
    Rectangle {
        anchors.fill: parent
        radius: 16
        clip: true
        gradient: Gradient {
            GradientStop { position: 0.0; color: backgroundColor }
            GradientStop { position: 1.0; color: Qt.darker(backgroundColor, 1.3) }
        }
    }

    //  顶部应用栏
    AppBar {
        id: appBar
        width: parent.width
        height: 110
        primaryColor: root.primaryColor
        textColor: root.textColor
        secondaryTextColor: root.secondaryTextColor
        currentTheme: appSettings.theme // 当前主题
        settingsMenu: settingsMenu
        windowRoot: root
    }

    // 进度条
    ProgressSection {
        id: progressSection
        width: parent.width - 50
        anchors.top: appBar.bottom
        anchors.topMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        primaryColor: root.primaryColor
        listModel: listmodel
    }

    // 任务列表
    TaskListView {
        id: listView
        width: parent.width - 40
        anchors.top: progressSection.bottom
        anchors.topMargin: 12
        anchors.bottom: bottomBar.top
        anchors.bottomMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        primaryColor: root.primaryColor
        textColor: root.textColor
        secondaryTextColor: root.secondaryTextColor
        surfaceColor: root.surfaceColor
        borderColor: root.borderColor
        listModel: listmodel
        fontSize: appSettings.fontSize
        isAdding: root.isAdding
    }

    // 底部操作栏
    BottomBar {
        id: bottomBar
        width: parent.width
        height: 100
        anchors.bottom: parent.bottom
        primaryColor: root.primaryColor
        secondaryTextColor: root.secondaryTextColor
        surfaceColor: root.surfaceColor
        borderColor: root.borderColor
        isAdding: root.isAdding
        listModel: listmodel
        windowRoot: root
    }

    // 输入面板
    TaskInputPanel {
        id: inputPanel
        width: parent.width - 40
        anchors.centerIn: parent
        primaryColor: root.primaryColor
        textColor: root.textColor
        secondaryTextColor: root.secondaryTextColor
        surfaceColor: root.surfaceColor
        borderColor: root.borderColor
        fontSize: appSettings.fontSize
        isAdding: root.isAdding
        listModel: listmodel
        bottomBarRef: bottomBar
        windowRoot: root
    }

    // 12. 设置菜单
    Menu {
        id: settingsMenu

        MenuItem {
            text: "🎨 主题颜色"
            onTriggered: colorDialog.open()
        }
        MenuItem {
            text: "🔤 字体大小"
            onTriggered: fontSizeDialog.open()
        }
        MenuItem {
            text: "🧹 清除已完成"
            onTriggered: {
                for (var i = listmodel.count - 1; i >= 0; i--) {
                    if (listmodel.get(i).completed){
                        listModelManager.deleteTask(listmodel.get(i).id)
                        listmodel.remove(i)
                    }
                }
            }
        }
        MenuItem {
            text: "ℹ️ 关于"
            onTriggered: aboutDialog.open()
        }
    }

    // 13. 对话框
    Dialog {
        id: fontSizeDialog
        title: "选择字体大小"
        modal: true
        anchors.centerIn: parent

        ColumnLayout {
            spacing: 15
            Text {
                text: "字体大小: " + fontSizeSlider.value + " px"
                font.pixelSize: 14
                color: secondaryTextColor
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Slider {
                id: fontSizeSlider
                from: 12; to: 24; stepSize: 1
                value: appSettings.fontSize
                Layout.preferredWidth: 200
                background: Rectangle {
                    x: fontSizeSlider.leftPadding
                    y: fontSizeSlider.topPadding + fontSizeSlider.availableHeight / 2 - 3
                    width: fontSizeSlider.availableWidth
                    height: 6; radius: 3
                    color: "#e0e0e0"
                    Rectangle {
                        width: fontSizeSlider.visualPosition * parent.width
                        height: parent.height; radius: 3
                        color: primaryColor
                    }
                }
                handle: Rectangle {
                    x: fontSizeSlider.leftPadding + fontSizeSlider.visualPosition * (fontSizeSlider.availableWidth - width)
                    y: fontSizeSlider.topPadding + fontSizeSlider.availableHeight / 2 - height / 2
                    width: 20; height: 20; radius: 10
                    color: "white"
                    border.width: 2; border.color: primaryColor
                }
                onValueChanged: appSettings.fontSize = value
            }
        }
    }

    Dialog {
        id: aboutDialog
        title: "关于"
        modal: true
        anchors.centerIn: parent

        ColumnLayout {
            spacing: 8
            Text {
                text: "📋 极简待办"
                font.pixelSize: 22; font.bold: true
                color: primaryColor
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: "版本 1.0.0"
                color: secondaryTextColor
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: "一个简洁优雅的待办事项应用"
                color: secondaryTextColor
                Layout.preferredWidth: 220
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    ColorDialog {
        id: colorDialog
        title: "选择主题颜色"
        selectedColor: appSettings.accentColor
        onAccepted: appSettings.accentColor = selectedColor
    }
}
