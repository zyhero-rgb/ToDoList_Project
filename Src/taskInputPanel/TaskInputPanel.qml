import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

/*
    模块：TaskInputPanel — 添加任务输入面板
    包含：弹出式输入框、动画
*/

Rectangle {
    id: inputRoot

    required property color primaryColor
    required property color textColor
    required property color secondaryTextColor
    required property color surfaceColor
    required property color borderColor
    required property int fontSize
    required property bool isAdding
    required property var listModel
    required property var bottomBarRef
    property var windowRoot: null

    width: 360
    height: 160
    radius: 18
    color: surfaceColor
    border.width: 1
    border.color: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.2)

    // 滑入/滑出
    y: isAdding ? (bottomBarRef ? bottomBarRef.top - height - 15 : 0) : (bottomBarRef ? bottomBarRef.top : 0)
    opacity: isAdding ? 1 : 0
    scale: isAdding ? 1 : 0.92

    Behavior on y { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 300 } }
    Behavior on scale { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }

    layer.enabled: true
    layer.effect: DropShadow {
        radius: 20; samples: 41
        color: "#25000000"; verticalOffset: 2
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 8

        RowLayout {
            Text {
                text: "✏️ 添加新任务"
                font.pixelSize: 15; font.bold: true
                color: inputRoot.textColor
            }
            Item { Layout.fillWidth: true }

            Rectangle {
                width: 28; height: 28; radius: 14
                color: closeInputArea.containsMouse ? "#15e74c3c" : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "×"; font.pixelSize: 18
                    color: closeInputArea.containsMouse ? "#e74c3c" : inputRoot.secondaryTextColor
                }

                MouseArea {
                    id: closeInputArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (inputRoot.windowRoot)
                            inputRoot.windowRoot.isAdding = false
                        taskInput.clear()
                    }
                }
            }
        }

        TextArea {
            id: taskInput
            Layout.fillWidth: true
            Layout.fillHeight: true
            font.pixelSize: inputRoot.fontSize
            placeholderText: "输入任务内容..."
            color: inputRoot.textColor
            placeholderTextColor: Qt.rgba(inputRoot.secondaryTextColor.r, inputRoot.secondaryTextColor.g, inputRoot.secondaryTextColor.b, 0.5)
            wrapMode: TextArea.Wrap
            selectByMouse: true
            background: Rectangle {
                radius: 10
                color: Qt.rgba(inputRoot.primaryColor.r, inputRoot.primaryColor.g, inputRoot.primaryColor.b, 0.04)
                border.width: 1
                border.color: taskInput.activeFocus
                              ? Qt.rgba(inputRoot.primaryColor.r, inputRoot.primaryColor.g, inputRoot.primaryColor.b, 0.3)
                              : Qt.rgba(inputRoot.borderColor.r, inputRoot.borderColor.g, inputRoot.borderColor.b, 0.5)
            }

            // 点击回车键添加任务
            Keys.onReturnPressed: function(event) {
                if (!(event.modifiers & Qt.ControlModifier)) {
                    var txt = taskInput.text.trim()
                    if (txt !== "" && inputRoot.listModel) {
                        // 获取新任务的ID
                        var newId = listModelManager.addTask(txt);
                        // 将新任务加入listModel
                        inputRoot.listModel.append({id: newId, task: txt, completed: false})
                        taskInput.clear()
                        if (inputRoot.windowRoot)
                            inputRoot.windowRoot.isAdding = false
                    }
                    event.accepted = true
                }
            }

            Keys.onEscapePressed: {
                taskInput.clear()
                if (inputRoot.windowRoot)
                    inputRoot.windowRoot.isAdding = false
            }

            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 10
                anchors.bottomMargin: 6
                text: "Enter 提交 · Esc 取消"
                font.pixelSize: 10
                color: Qt.rgba(inputRoot.secondaryTextColor.r, inputRoot.secondaryTextColor.g, inputRoot.secondaryTextColor.b, 0.4)
            }
        }
    }
}

