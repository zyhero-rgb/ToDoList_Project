import QtQuick
import QtQuick.Controls
import QtQuick.Layouts


// 模块：AppBar — 顶部应用栏
// 包含：Logo、标题、日期、主题切换、设置按钮、关闭按钮


Rectangle {
    id: appBarRoot

    // ── 外部属性 ──
    required property color primaryColor // 主题颜色
    required property color textColor  // 字体颜色
    required property color secondaryTextColor
    required property string currentTheme // 主题，用于切换夜间和白天模式
    property var settingsMenu: null
    property var windowRoot: null

    width: 400
    height: 110
    color: "transparent"

    // 窗口拖拽
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        property point lastPos: Qt.point(0, 0)
        onPressed: function(mouse) { lastPos = Qt.point(mouse.x, mouse.y) }
        onPositionChanged: function(mouse) {
            if (pressed && appBarRoot.windowRoot) {
                appBarRoot.windowRoot.x += mouse.x - lastPos.x
                appBarRoot.windowRoot.y += mouse.y - lastPos.y
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.topMargin: 5

        // Logo
        Rectangle {
            id: logoBox
            width: 44; height: 44; radius: 14
            color: appBarRoot.primaryColor
            antialiasing: true

            Rectangle {
                anchors.fill: parent; radius: 14
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#30ffffff" }
                    GradientStop { position: 0.5; color: "transparent" }
                    GradientStop { position: 1.0; color: "#10000000" }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "✓"; color: "white"
                font.pixelSize: 22; font.bold: true
            }

            MouseArea {
                anchors.fill: parent
                onClicked: logoScaleAnim.restart()
            }

            PropertyAnimation {
                id: logoScaleAnim
                target: logoBox; property: "scale"
                from: 1.0; to: 1.15; duration: 120
                easing.type: Easing.OutBack
            }
            PropertyAnimation {
                id: logoScaleBack
                target: logoBox; property: "scale"
                to: 1.0; duration: 200
                easing.type: Easing.OutElastic
            }
            onScaleChanged: {
                if (scale > 1.14 && !logoScaleAnim.running && !logoScaleBack.running)
                    logoScaleBack.restart()
            }
        }

        // 标题
        Column {
            Layout.leftMargin: 12
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: "今日待办"
                font.pixelSize: 22; font.bold: true
                color: appBarRoot.textColor
            }
            Text {
                text: new Date().toLocaleDateString(Qt.locale(), "MM月dd日 dddd")
                font.pixelSize: 12
                color: appBarRoot.secondaryTextColor
                opacity: 0.8
            }
        }

        Item { Layout.fillWidth: true }

        // 主题切换
        Rectangle {
            id: themeToggle
            width: 42; height: 42; radius: 21
            color: themeToggleArea.containsMouse
                   ? Qt.rgba(appBarRoot.primaryColor.r, appBarRoot.primaryColor.g, appBarRoot.primaryColor.b, 0.12)
                   : "transparent"

            Image {
                anchors.centerIn: parent
                width: 22; height: 22
                fillMode: Image.PreserveAspectFit; smooth: true
                source: appBarRoot.currentTheme === "light" ? "qrc:/ToDoList_Project/images/moon.png" : "qrc:/ToDoList_Project/images/sun.png"
            }

            MouseArea {
                id: themeToggleArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    themeAnim.restart()
                    if (appBarRoot.windowRoot)
                        appBarRoot.windowRoot.toggleTheme()
                }
            }

            RotationAnimation on rotation {
                id: themeAnim
                from: 0; to: 360; duration: 400
                easing.type: Easing.OutCubic
            }

            ToolTip {
                visible: themeToggleArea.containsMouse
                text: appBarRoot.currentTheme === "light" ? "切换深色模式" : "切换浅色模式"
                delay: 600
            }
        }

        // 设置按钮
        Rectangle {
            id: settingsBtn
            width: 42; height: 42; radius: 21
            color: settingsArea.containsMouse
                   ? Qt.rgba(appBarRoot.primaryColor.r, appBarRoot.primaryColor.g, appBarRoot.primaryColor.b, 0.12)
                   : "transparent"

            Image {
                anchors.centerIn: parent
                width: 20; height: 20
                fillMode: Image.PreserveAspectFit; smooth: true
                source: "qrc:/ToDoList_Project/images/settings.png"
            }

            MouseArea {
                id: settingsArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (appBarRoot.settingsMenu) appBarRoot.settingsMenu.popup()
                }
            }

            ToolTip {
                visible: settingsArea.containsMouse
                text: "设置"; delay: 600
            }
        }

        // 关闭
        Rectangle {
            id: closeBtn
            width: 42; height: 42; radius: 21
            color: closeArea.containsMouse ? "#20e74c3c" : "transparent"

            Text {
                anchors.centerIn: parent
                text: "×"
                font.pixelSize: 22; font.bold: true
                color: closeArea.containsMouse ? "#e74c3c" : appBarRoot.secondaryTextColor
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { if (appBarRoot.windowRoot) appBarRoot.windowRoot.close() }
            }

            ToolTip {
                visible: closeArea.containsMouse
                text: "关闭"; delay: 600
            }
        }
    }
}

