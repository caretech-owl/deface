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

    }
    Connections {
        function onStatusUpdated(taskId, currentProgress, outPath) {
            fileList.get(taskId).progress = currentProgress;
            totalProgressBar.value = taskId + (currentProgress == 1 ? 1 : 0) / fileList.count;
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
                    resultUrl: "",
                    progress: 0
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
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 5
                spacing: 10

                ColumnLayout {
                    Text {
                        text: "Replace With"
                    }
                    ComboBox {
                        id: replaceWithBox

                        ToolTip.text: "When a face is detected, it will be replaced with the selected pattern."
                        ToolTip.visible: hovered
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

                        ToolTip.text: "Lower values will detect more faces, higher values will detect fewer faces."
                        ToolTip.visible: hovered
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

                        ToolTip.text: "The size of the mask used to replace the face. Should be larger than 1 to cover the whole face."
                        ToolTip.visible: hovered
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

                        ToolTip.text: "The size of the mosaic pattern in pixel. Only used when 'mosaic' is selected."
                        ToolTip.visible: hovered
                        editable: true
                        enabled: replaceWithBox.currentText === "mosaic"
                        from: 1
                        stepSize: 1
                        to: 1000
                        value: 10
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 5
                spacing: 10

                ColumnLayout {
                    Text {
                        text: "Offset X"
                    }
                    SpinBox {
                        id: offsetXBox

                        ToolTip.text: "The horizontal offset of the mask. Positive values will move the mask to the right, negative values to the left."
                        ToolTip.visible: hovered
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

                        ToolTip.text: "The vertical offset of the mask. Positive values will move the mask down, negative values up."
                        ToolTip.visible: hovered
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

                        ToolTip.text: "For videos, you can choose to just copy the audio track unedited, distort it or remove it."
                        ToolTip.visible: hovered
                        model: ["drop", "copy", "distort"]
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

                        ToolTip.text: "If enabled, existing files will not be overwritten."
                        ToolTip.visible: hovered
                        position: 0
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter

                // Layout.margins: 10
                // spacing: 10

                ColumnLayout {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.margins: 10

                    // Layout.maximumWidth: parent.width * 0.5

                    Text {
                        font.pointSize: 20
                        font.weight: 400
                        text: "File List"
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "You can either click the file name to open the file or click the cross to remove the file from the list. Results will be written to the sources directory with a '_anonymized' suffix. The icon on the right will open the anonymized file."
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                    ScrollView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        clip: true

                        ListView {
                            id: listView

                            model: fileList

                            delegate: Item {
                                height: 45
                                width: listView.width - 20

                                RowLayout {
                                    Layout.alignment: Qt.AlignLeft
                                    width: parent.width

                                    Button {
                                        enabled: totalProgressBar.value == 1.0
                                        icon.source: appRoot + "/data/delete.svg"

                                        background: Rectangle {
                                            border.width: 1
                                            radius: 4
                                        }

                                        onClicked: {
                                            fileList.remove(index);
                                        }
                                    }
                                    Button {
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true

                                        background: Rectangle {
                                            border.width: 1
                                            radius: 4

                                            Rectangle {
                                                anchors.left: parent.left
                                                anchors.leftMargin: 1
                                                anchors.verticalCenter: parent.verticalCenter
                                                color: "lightgreen"
                                                height: parent.height - 2
                                                radius: 4
                                                width: progress * parent.width - 2
                                            }
                                        }
                                        contentItem: Text {
                                            horizontalAlignment: Text.AlignLeft
                                            text: name
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        onClicked: {
                                            Qt.openUrlExternally(url);
                                        }
                                    }
                                    Button {
                                        enabled: progress == 1.0
                                        icon.source: appRoot + "/data/defaced.svg"

                                        background: Rectangle {
                                            border.width: 1
                                            radius: 4
                                        }

                                        onClicked: {
                                            Qt.openUrlExternally(resultUrl);
                                        }
                                    }
                                }
                            }

                            Label {
                                anchors.fill: parent
                                font.bold: true
                                horizontalAlignment: Qt.AlignHCenter
                                text: "Drag your images and videos here to process them."
                                verticalAlignment: Qt.AlignVCenter
                                visible: parent.count == 0
                            }
                        }
                    }
                }
            }
            Button {
                id: defaceButton

                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 200
                enabled: totalProgressBar.value == 1.0 && fileList.count > 0
                text: "Deface!"

                onClicked: {
                    totalProgressBar.value = 0;
                    for (var i = 0; i < fileList.count; i++) {
                        let resultUrl = backend.submit(fileList.get(i).url, replaceWithBox.currentText, threshBox.realValue, maskScaleBox.realValue, offsetXBox.value, offsetYBox.value, mosaicSizeBox.value, skipExistingSwitch.position, audioBox.currentText);
                        fileList.get(i).resultUrl = resultUrl;
                    }
                    backend.start();
                }
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
