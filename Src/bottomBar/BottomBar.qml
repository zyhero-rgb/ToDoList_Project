import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

/*
    模块：BottomBar — 底部操作栏
    包含：圆角底部栏、统计文字、居中浮动添加按钮、纯QML粒子动画、清除已完成按钮
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

    // ── 底部圆角，与背景渐变 Rectangle 的 radius=16 匹配 ──
    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "transparent"
        clip: true

        // 顶部分割线
        Rectangle {
            width: parent.width
            height: 1
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

    // ═══════════════════════════════════════
    // 粒子动画 — 纯 QML Repeater + 动画
    // ═══════════════════════════════════════
    property var particles: []
    property int particleCount: 12

    Component.onCompleted: {
        for (var i = 0; i < particleCount; i++) {
            particles.push({
                x: 0, y: 0, opacity: 0, scale: 1,
                angle: Math.random() * 360,
                distance: 40 + Math.random() * 60,
                duration: 400 + Math.random() * 300
            })
        }
    }

    function burstParticles() {
        var cx = fabButton.x + fabButton.width / 2
        var cy = fabButton.y + fabButton.height / 2
        for (var i = 0; i < particleCount; i++) {
            var p = particles[i]
            p.angle = Math.random() * 360
            p.distance = 40 + Math.random() * 60
            p.duration = 400 + Math.random() * 300
            p.x = cx
            p.y = cy
            p.opacity = 1
            p.scale = 1
            particles[i] = p  // 触发绑定更新
        }
        // 延迟复位
        particleTimer.restart()
    }

    Timer {
        id: particleTimer
        interval: 50
        onTriggered: {
            for (var i = 0; i < particleCount; i++) {
                var p = particles[i]
                p.opacity = 0
                p.scale = 0
                particles[i] = p
            }
        }
    }

    Repeater {
        model: particleCount

        Rectangle {
            id: spark
            width: 8; height: 8; radius: 4
            color: bottomBarRoot.primaryColor
            opacity: 0
            scale: 0
            x: particles[index] ? particles[index].x - width / 2 : 0
            y: particles[index] ? particles[index].y - height / 2 : 0

            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 200 } }

            // 飞出动画
            NumberAnimation on x {
                id: flyX
                running: particles[index] ? particles[index].opacity > 0 : false
                from: particles[index] ? particles[index].x - width / 2 : 0
                to: particles[index]
                    ? particles[index].x - width / 2 + Math.cos(particles[index].angle * Math.PI / 180) * particles[index].distance
                    : 0
                duration: particles[index] ? particles[index].duration : 500
                easing.type: Easing.OutQuad
            }
            NumberAnimation on y {
                id: flyY
                running: particles[index] ? particles[index].opacity > 0 : false
                from: particles[index] ? particles[index].y - height / 2 : 0
                to: particles[index]
                    ? particles[index].y - height / 2 + Math.sin(particles[index].angle * Math.PI / 180) * particles[index].distance
                    : 0
                duration: particles[index] ? particles[index].duration : 500
                easing.type: Easing.OutQuad
            }
            NumberAnimation on opacity {
                running: particles[index] ? particles[index].opacity > 0 : false
                to: 0
                duration: particles[index] ? particles[index].duration : 500
                easing.type: Easing.InQuad
            }
            NumberAnimation on scale {
                running: particles[index] ? particles[index].opacity > 0 : false
                to: 0.2
                duration: particles[index] ? particles[index].duration : 500
                easing.type: Easing.InQuad
            }
        }
    }

    // ═══════════════════════════════════════
    // 居中浮动添加按钮
    // ═══════════════════════════════════════
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
                bottomBarRoot.burstParticles()
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
            if (!bottomBarRoot.listModel) return false
            for (var i = 0; i < bottomBarRoot.listModel.count; i++)
                if (bottomBarRoot.listModel.get(i).completed) return true
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
                        bottomBarRoot.listModel.remove(i)
                }
                if (typeof saveData === "function") saveData()
            }
        }

        ToolTip {
            visible: clearArea.containsMouse
            text: "清除已完成任务"; delay: 600
        }
    }
}

