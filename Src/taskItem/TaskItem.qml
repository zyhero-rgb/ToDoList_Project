import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Layouts
/*
    模块：TaskItem — 单个任务项组件
    包含：复选框、文本、删除按钮、动画
*/

Rectangle {
    id: taskItem

    property string taskText: ""
    property bool isCompleted: false
    property int index: 0
    property color itemPrimaryColor: "#4361ee"
    property color itemTextColor: "#2d3436"
    property color itemSecondaryTextColor: "#636e72"
    property color itemSurfaceColor: "#ffffff"
    property color itemBorderColor: "#dfe6e9"
    property int itemFontSize: 16

    signal toggleCompleted
    signal deleteTask

    height: 64
    radius: 14
    color: isCompleted
           ? Qt.rgba(itemPrimaryColor.r, itemPrimaryColor.g, itemPrimaryColor.b, 0.06)
           : itemSurfaceColor
    border.width: 1
    border.color: isCompleted
                  ? Qt.rgba(itemPrimaryColor.r, itemPrimaryColor.g, itemPrimaryColor.b, 0.15)
                  : Qt.rgba(itemBorderColor.r, itemBorderColor.g, itemBorderColor.b, 0.5)

    layer.enabled: true
    layer.effect: DropShadow {
        radius: 6; samples: 13
        color: "#12000000"; verticalOffset: 1
    }

    scale: mouseArea.containsMouse && !isCompleted ? 1.015 : 1.0
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    // 左侧彩色指示条
    Rectangle {
        width: 4
        height: parent.height - 16
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        radius: 2
        color: isCompleted ? Qt.rgba(itemPrimaryColor.r, itemPrimaryColor.g, itemPrimaryColor.b, 0.35) : itemPrimaryColor
        opacity: isCompleted ? 0.5 : 1.0
        Behavior on opacity { NumberAnimation { duration: 300 } }
        Behavior on color { ColorAnimation { duration: 300 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 12
        spacing: 12

        // 完成复选框
        Rectangle {
            id: completeButton
            width: 26; height: 26; radius: 13
            color: isCompleted ? itemPrimaryColor : "transparent"
            border.width: 2
            border.color: isCompleted ? itemPrimaryColor : Qt.rgba(itemSecondaryTextColor.r, itemSecondaryTextColor.g, itemSecondaryTextColor.b, 0.4)
            Behavior on color { ColorAnimation { duration: 250 } }
            Behavior on border.color { ColorAnimation { duration: 250 } }

            Text {
                anchors.centerIn: parent
                text: "✓"; color: "white"
                font.pixelSize: 13; font.bold: true
                opacity: isCompleted ? 1 : 0
                scale: isCompleted ? 1 : 0.5
                Behavior on opacity { NumberAnimation { duration: 200 } }
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: taskItem.toggleCompleted()
            }
        }

        // 任务文本
        Text {
            id: taskLabel
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: taskText
            font.pixelSize: itemFontSize
            color: isCompleted ? itemSecondaryTextColor : itemTextColor
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            maximumLineCount: 2
            Behavior on color { ColorAnimation { duration: 300 } }

            // 删除线
            Rectangle {
                width: isCompleted ? parent.width : 0
                height: 1.5
                anchors.verticalCenter: parent.verticalCenter
                color: itemSecondaryTextColor
                opacity: 0.6
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }

        // 删除按钮
        Rectangle {
            id: deleteButton
            width: 32; height: 32; radius: 16
            color: deleteArea.containsMouse ? "#15e74c3c" : "transparent"
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: "×"
                color: deleteArea.containsMouse ? "#e74c3c" : Qt.rgba(itemSecondaryTextColor.r, itemSecondaryTextColor.g, itemSecondaryTextColor.b, 0.4)
                font.pixelSize: 20; font.bold: true
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            MouseArea {
                id: deleteArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: taskItem.deleteTask()
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: taskItem.toggleCompleted()
        propagateComposedEvents: true
    }

    // 删除动画
    SequentialAnimation {
        id: deleteAnimation
        ParallelAnimation {
            NumberAnimation { target: taskItem; property: "opacity"; to: 0; duration: 250 }
            NumberAnimation { target: taskItem; property: "scale"; to: 0.7; duration: 250 }
            NumberAnimation { target: taskItem; property: "x"; to: taskItem.x - 60; duration: 250; easing.type: Easing.InCubic }
        }
        ScriptAction {
            script: {
                if (typeof listmodel !== "undefined") {
                    listModelManager.deleteTask(listmodel.get(index).id)
                    listmodel.remove(index)
                }
            }
        }
    }
}

