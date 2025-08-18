import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    anchors.fill: parent


    Rectangle
    {
        color:"grey"
        anchors
        {
            top:parent.top
            topMargin:80
            left:parent.left
            right:parent.right
            bottom:parent.bottom
        }
        Text {
            id:downloadStatusText

            anchors
            {
                top:parent.top
                horizontalCenter:parent.horizontalCenter
            }

            text: ""
        }
        ListView {
            id: listView
            anchors.fill: parent
            model: urlModel

            delegate: ItemDelegate {
                width: parent.width
                text: model.name
                onClicked: {
                    backend.download(model.url, model.name)
                }
            }
        }

        // ProgressBar {
        //     id: progressBar
        //     width: parent.width
        //     from: 0
        //     to: 100
        //     value: 0
        //     anchors.bottom: parent.bottom
        //     anchors.left: parent.left
        //     anchors.right: parent.right
        //     visible: false
        // }

        ListModel {
            id: urlModel
        }


    }


    Connections {
        target: backend
        onUrlListFailed: {
            console.log("Failed to fetch URL list:", errorString)
            downloadStatusText.text =  "Error: " + errorString
        }

        onUrlListReady: {
            urlModel.clear()
            for (var i = 0; i < list.length; i++) {
                urlModel.append(list[i])
            }
        }
        onDownloadProgress: {
            // progressBar.visible = true
            if (bytesTotal > 0) {
                // progressBar.value = (bytesReceived / bytesTotal) * 100
                downloadStatusText.text = (bytesReceived / bytesTotal) * 100
            }
        }
        onDownloadFinished: {
            // progressBar.visible = false
            if (success) {
                console.log("Downloaded to:", filePath)
                downloadStatusText.text = "downloaded successfylly";
            } else {
                console.log("Download failed")
                downloadStatusText.text = "downloaded failed";
            }
        }
    }

    Component.onCompleted: {
        backend.fetchUrlList()
    }
}
