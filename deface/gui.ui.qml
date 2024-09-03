import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    function basename(str) {
        return (str.slice(str.lastIndexOf("/") + 1));
    }

    height: 800
    title: "Deface GUI"
    visible: true
    width: 800

    ListModel {
        id: fileList

        ListElement {
            done: false
            name: "test.mov"
            resultUrl: ""
            url: "file:///Users/aneumann9/workspace/deface/test.mov"
        }
        ListElement {
            done: false
            name: "MarénSchorch.jpeg"
            resultUrl: ""
            url: "file:///Users/aneumann9/workspace/deface/IMG_7031_MarénSchorch.jpeg"
        }
    }
    Connections {
        function onStatusUpdated(taskId, currentProgress, frame, outPath) {
            fileList.get(taskId).done = currentProgress == 1;
            currentProgressBar.value = currentProgress;
            totalProgressBar.value = taskId + (currentProgress == 1 ? 1 : 0) / fileList.count;
            preview_image.source = frame;
        }

        target: backend
    }
    DropArea {
        anchors.fill: parent

        onDropped: function (drop) {
            for (var i = 0; i < drop.urls.length; i++) {
                fileList.append({
                    name: basename(drop.urls[i].toString()),
                    url: drop.urls[i].toString(),
                    done: false,
                    resultUrl: ""
                });
            }
        }

        ColumnLayout {
            anchors.fill: parent

            Text {
                id: titleText

                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10
                Layout.topMargin: 20
                font.pointSize: 20
                font.weight: 800
                text: "Deface"
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: 10
                font.pointSize: 20
                text: "Drag your images and videos into this app to process them."
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 10
                spacing: 10

                ColumnLayout {
                    Text {
                        text: "Replace With"
                    }
                    ComboBox {
                        id: replaceWithBox

                        model: ["blur", "solid", "none", "image", "mosaic"]
                        width: 200
                    }
                }
                ColumnLayout {
                    Text {
                        text: "Threshold"
                    }
                    SpinBox {
                        id: threshBox

                        readonly property int decimalFactor: Math.pow(10, decimals)
                        property int decimals: 2
                        property real realValue: value / decimalFactor

                        function decimalToInt(decimal) {
                            return decimal * decimalFactor;
                        }

                        editable: true
                        from: decimalToInt(0)
                        stepSize: 5
                        textFromValue: function (value, locale) {
                            return Number(value / decimalFactor).toLocaleString(locale, 'f', threshBox.decimals);
                        }
                        to: decimalToInt(1)
                        value: decimalToInt(0.2)
                        valueFromText: function (text, locale) {
                            return Math.round(Number.fromLocaleString(locale, text) * decimalFactor);
                        }

                        validator: DoubleValidator {
                            bottom: Math.min(threshBox.from, threshBox.to)
                            decimals: threshBox.decimals
                            notation: DoubleValidator.StandardNotation
                            top: Math.max(threshBox.from, threshBox.to)
                        }
                    }
                }
                ColumnLayout {
                    Text {
                        text: "Mask Scale"
                    }
                    SpinBox {
                        id: maskScaleBox

                        readonly property int decimalFactor: Math.pow(10, decimals)
                        property int decimals: 1
                        property real realValue: value / decimalFactor

                        function decimalToInt(decimal) {
                            return decimal * decimalFactor;
                        }

                        editable: true
                        from: decimalToInt(0.7)
                        stepSize: 1
                        textFromValue: function (value, locale) {
                            return Number(value / decimalFactor).toLocaleString(locale, 'f', maskScaleBox.decimals);
                        }
                        to: decimalToInt(3)
                        value: decimalToInt(1.3)
                        valueFromText: function (text, locale) {
                            return Math.round(Number.fromLocaleString(locale, text) * decimalFactor);
                        }

                        validator: DoubleValidator {
                            bottom: Math.min(maskScaleBox.from, maskScaleBox.to)
                            decimals: maskScaleBox.decimals
                            notation: DoubleValidator.StandardNotation
                            top: Math.max(maskScaleBox.from, maskScaleBox.to)
                        }
                    }
                }
                ColumnLayout {
                    Text {
                        text: "Mosaic Size"
                    }
                    SpinBox {
                        id: mosaicSizeBox

                        editable: true
                        from: 1
                        stepSize: 1
                        to: 1000
                        value: 10
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 10
                spacing: 10

                ColumnLayout {
                    Text {
                        text: "Offset X"
                    }
                    SpinBox {
                        id: offsetXBox

                        editable: true
                        from: -1000
                        stepSize: 1
                        to: 1000
                        value: 0
                    }
                }
                ColumnLayout {
                    Text {
                        text: "Offset Y"
                    }
                    SpinBox {
                        id: offsetYBox

                        editable: true
                        from: -1000
                        stepSize: 1
                        to: 1000
                        value: 0
                    }
                }
                ColumnLayout {
                    Text {
                        text: "Audio"
                    }
                    ComboBox {
                        id: audioBox

                        model: ["none", "distort", "keep"]
                        width: 200
                    }
                }
                ColumnLayout {
                    Layout.alignment: Qt.AlignTop

                    Text {
                        text: "Skip Existing"
                    }
                    Switch {
                        id: skipExistingSwitch

                        position: 0
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 10
                spacing: 10

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.margins: 10
                    Layout.maximumWidth: parent.width * 0.5
                    border.color: "black"
                    border.width: 5
                    height: 100
                    radius: 5

                    Text {
                        id: preview_label

                        anchors.centerIn: parent
                        text: "Image Preview"
                    }
                    Image {
                        id: preview_image

                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        height: parent.height - 10
                        source: ""
                        width: parent.width - 10
                    }
                }
                ColumnLayout {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.margins: 10
                    Layout.maximumWidth: parent.width * 0.5

                    Text {
                        text: "File List (click on name to open; click on x to remove)"
                    }
                    ListView {
                        id: listView

                        Layout.fillWidth: true
                        // Layout.maximumWidth: parent.width * 0.5
                        height: 200
                        model: fileList

                        delegate: Item {
                            height: 40
                            width: listView.width

                            RowLayout {
                                Layout.alignment: Qt.AlignLeft
                                width: parent.width

                                Button {

                                    background: Rectangle {
                                        border.width: 1
                                        radius: 4
                                    }

                                    onClicked: {
                                        fileList.remove(index);
                                    }
                                }
                                // Button {
                                //     Layout.fillWidth: true
                                //     Layout.rightMargin: 5

                                //     background: Rectangle {
                                //         border.width: 1
                                //         color: done ? "lightgreen" : "white"
                                //         radius: 4
                                //     }
                                //     contentItem: Text {
                                //         horizontalAlignment: Text.AlignLeft
                                //         text: name.length > 20 ? name.substring(0, 20) + "..." : name
                                //     }

                                //     onClicked: {
                                //         if (fileList.get(index).done == true) {
                                //             Qt.openUrlExternally(fileList.get(index).resultUrl);
                                //         } else {
                                //             Qt.openUrlExternally(fileList.get(index).url);
                                //         }
                                //     }
                                // }
                                // Button {
                                //     Layout.preferredWidth: 50
                                //     text: "❌"

                                //     background: Rectangle {
                                //         border.width: 1
                                //         radius: 4
                                //     }

                                //     onClicked: {
                                //         fileList.remove(index);
                                //     }
                                // }
                                Button {
                                    icon.source: "./data/person.svg"

                                    background: Rectangle {
                                        border.width: 1
                                        radius: 4
                                    }

                                    onClicked: {
                                        // fileList.remove(index);
                                    }
                                }
                                Button {
                                    icon.source: "./data/defaced.svg"

                                    background: Rectangle {
                                        border.width: 1
                                        radius: 4
                                    }

                                    onClicked: {
                                        // fileList.remove(index);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            Button {
                id: defaceButton

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                text: "Deface!"

                onClicked: {
                    defaceButton.enabled = false;
                    totalProgressBar.value = 0;
                    for (var i = 0; i < fileList.count; i++) {
                        let resultUrl = backend.submit(fileList.get(i).url, replaceWithBox.currentText, threshBox.realValue, maskScaleBox.realValue, offsetXBox.value, offsetYBox.value, mosaicSizeBox.value, skipExistingSwitch.position);
                        // preview_image.source = "";
                        // if (resultUrl.endsWith("jpeg") || resultUrl.endsWith("png") || resultUrl.endsWith("jpg")) {
                        //     preview_image.source = resultUrl;
                        // } else {
                        //     preview_label.text = "No preview available";
                        // }
                        fileList.get(i).resultUrl = resultUrl;
                        // processProgress.value = (i + 1) / fileList.count;
                    }
                    backend.start();
                    // defaceButton.enabled = true;
                }
            }
            ProgressBar {
                id: currentProgressBar

                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.margins: 10
                value: 0
            }
            ProgressBar {
                id: totalProgressBar

                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.margins: 10
                value: 1
            }
        }
    }
}
