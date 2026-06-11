import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

/*
    模块：BottomBar — 底部操作栏
    包含：圆角底部栏、统计文字、居中浮动添加按钮、脉冲动画、清除已完成按钮
*/

Rectangle {
    id: bottomBarRoot

    required property color primaryColor
    required property color secondaryTextColor
    required property color surfaceColor
    required property color borderColor
    required property bool isAdding
    required property var listModel
    property var windowRoot: null

    width: parent ? parent.width : 400
    height: 100
    color: surfaceColor
    radius: 16

    // ── 底部圆角，与背景渐变 Rectangle 的 radius=16 匹配 ──
    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "transparent"
        clip: true

        // 顶部分割线
        Rectangle {
            width: parent.width
            height: 2
            radius: 1
            anchors.top: parent.top
            color: Qt.rgba(borderColor.r, borderColor.g, borderColor.b, 0.4)
        }

        // 统计文字
        Text {
            id: bottomStats
            anchors.horizontalCenter: parent.horizontalCenter
            y: 10
            text: {
                if (!bottomBarRoot.listModel || bottomBarRoot.listModel.count === 0) return "暂无任务"
                var total = bottomBarRoot.listModel.count
                var done = 0
                for (var i = 0; i < total; i++)
                    if (bottomBarRoot.listModel.get(i).completed) done++
                if (done === total) return "🎉 全部完成！"
                return done + " / " + total + " 已完成"
            }
            font.pixelSize: 11
            color: secondaryTextColor
        }
    }


    // 居中浮动添加按钮
    Rectangle {
        id: fabButton
        width: 56; height: 56; radius: 28
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        color: bottomBarRoot.isAdding ? "#e74c3c" : bottomBarRoot.primaryColor
        Behavior on color { ColorAnimation { duration: 250 } }

        layer.enabled: true
        layer.effect: DropShadow {
            radius: 10; samples: 21
            color: Qt.rgba(bottomBarRoot.primaryColor.r, bottomBarRoot.primaryColor.g, bottomBarRoot.primaryColor.b, 0.4)
            verticalOffset: 2
        }

        Text {
            anchors.centerIn: parent
            text: bottomBarRoot.isAdding ? "×" : "+"
            font.pixelSize: 28
            color: "white"

            RotationAnimation on rotation {
                id: fabRotateAnim
                from: 0; to: bottomBarRoot.isAdding ? 90 : 0
                duration: 300; easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (bottomBarRoot.windowRoot)
                    bottomBarRoot.windowRoot.isAdding = !bottomBarRoot.windowRoot.isAdding
                if (bottomBarRoot.windowRoot && bottomBarRoot.windowRoot.isAdding)
                    fabRotateAnim.restart()
            }
        }

        // 脉冲波纹
        Rectangle {
            id: pulseRing
            anchors.fill: parent; radius: 28
            color: "transparent"
            border.width: 2
            border.color: Qt.rgba(bottomBarRoot.primaryColor.r, bottomBarRoot.primaryColor.g, bottomBarRoot.primaryColor.b, 0.5)
            opacity: bottomBarRoot.isAdding ? 0 : 0.6
            scale: 1

            SequentialAnimation on scale {
                running: !bottomBarRoot.isAdding
                loops: Animation.Infinite
                NumberAnimation { to: 1.35; duration: 1800; easing.type: Easing.OutCubic }
                PauseAnimation { duration: 200 }
                PropertyAction { target: pulseRing; property: "scale"; value: 1 }
            }

            SequentialAnimation on opacity {
                running: !bottomBarRoot.isAdding
                loops: Animation.Infinite
                NumberAnimation { to: 0; duration: 1800; easing.type: Easing.OutCubic }
                PauseAnimation { duration: 200 }
                PropertyAction { target: pulseRing; property: "opacity"; value: 0.6 }
            }
        }
    }

    // ── 清除已完成按钮（左下角小型）──
    Rectangle {
        id: clearDoneBtn
        width: 28; height: 28; radius: 14
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        color: clearArea.containsMouse ? "#15e74c3c" : "transparent"
        visible: {
            if (!bottomBarRoot.listModel){
                return false
            }
            for (var i = 0; i < bottomBarRoot.listModel.count; i++){
                if (bottomBarRoot.listModel.get(i).completed){
                    return true
                }
            }
            return false
        }

        Text {
            anchors.centerIn: parent
            text: "🗑"; font.pixelSize: 13
        }

        MouseArea {
            id: clearArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!bottomBarRoot.listModel) return
                for (var i = bottomBarRoot.listModel.count - 1; i >= 0; i--) {
                    if (bottomBarRoot.listModel.get(i).completed)
                        listModelManager.deleteTask(bottomBarRoot.listModel.get(i).id)
                        bottomBarRoot.listModel.remove(i)
                }
            }
        }

        ToolTip {
            visible: clearArea.containsMouse
            text: "清除已完成任务"; delay: 600
        }
    }
}

