import QtQuick
import QtQuick.Layouts

/*
    模块：ProgressSection — 进度条区域
    包含：进度条、统计文字、分割线
*/

Column {
    id: progressRoot

    required property color primaryColor
    required property var listModel

    width: 350
    spacing: 6

    // 仅当有任务时显示
    visible: listModel ? listModel.count > 0 : false

    // 进度条 + 统计
    RowLayout {
        width: parent.width
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            radius: 3
            color: Qt.rgba(progressRoot.primaryColor.r, progressRoot.primaryColor.g, progressRoot.primaryColor.b, 0.15)

            Rectangle {
                id: progressFill
                height: parent.height
                radius: 3
                color: progressRoot.primaryColor
                width: {
                    if (!progressRoot.listModel) return 0
                    var total = progressRoot.listModel.count
                    if (total === 0) return 0
                    var done = 0
                    for (var i = 0; i < total; i++)
                        if (progressRoot.listModel.get(i).completed) done++
                    return parent.width * (done / total)
                }
                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            }
        }

        Text {
            id: progressText
            text: {
                if (!progressRoot.listModel || progressRoot.listModel.count === 0) return "暂无任务"
                var total = progressRoot.listModel.count
                var done = 0
                for (var i = 0; i < total; i++)
                    if (progressRoot.listModel.get(i).completed) done++
                return "已完成 " + done + "/" + total
            }
            font.pixelSize: 11; font.bold: true
            color: progressRoot.primaryColor
            Layout.preferredWidth: 80
            horizontalAlignment: Text.AlignRight
        }
    }

    // 分割线
    Rectangle {
        width: parent.width
        height: 1
        radius: 0.5
        color: Qt.rgba(progressRoot.primaryColor.r, progressRoot.primaryColor.g, progressRoot.primaryColor.b, 0.1)
        antialiasing: true
    }
}

