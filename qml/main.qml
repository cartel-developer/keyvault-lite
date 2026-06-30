import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    id: root
    width: 900
    height: 620
    visible: true
    title: "Qt5 QML Key-Value"

    property bool showListPage: false
    property var selectedItem: ({})

    function loadItemsToModel() {
        itemsModel.clear()
        const list = formController.items
        for (let i = 0; i < list.length; ++i) {
            const item = list[i]
            itemsModel.append({
                id: item.id,
                keyText: item.key,
                valueText: item.value
            })
        }
    }

    ColumnLayout {
        id: mainPage
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10
        visible: !showListPage

        Rectangle {
            Layout.fillWidth: true
            height: 120

            Image {
                anchors.fill: parent
                anchors.margins: 5
                source: "icon.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        Label {
            text: "key-value DB"
            font.pixelSize: 24
            Layout.alignment: Qt.AlignHCenter
        }

        TextField {
            id: keyField
            placeholderText: "key"
            Layout.fillWidth: true
        }

        TextField {
            id: valueField
            placeholderText: "value"
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: 10
            Layout.fillWidth: true

            Button {
                text: "Save"
                Layout.fillWidth: true
                onClicked: formController.submitForm(keyField.text, valueField.text)
            }

            Button {
                text: "Clear"
                Layout.fillWidth: true
                onClicked: formController.clearForm()
            }

            Button {
                text: "List"
                Layout.fillWidth: true
                onClicked: {
                    formController.loadItems()
                    loadItemsToModel()
                    showListPage = true
                }
            }
        }

        Label {
            text: formController.statusMessage
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    Item {
        id: listPage
        anchors.fill: parent
        visible: showListPage

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Label {
                    text: "Stored Items"
                    font.pixelSize: 24
                    Layout.fillWidth: true
                }

                Button {
                    text: "Back"
                    onClicked: showListPage = false
                }

                Button {
                    text: "Refresh"
                    onClicked: formController.loadItems()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#d0d0d0"
            }

            Rectangle {
                id: tableContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                border.color: "#cccccc"
                border.width: 1
                color: "transparent"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        height: 36
                        Layout.fillWidth: true
                        color: "#ececec"

                        Row {
                            anchors.fill: parent
                            spacing: 0

                            Rectangle { width: 80; height: parent.height; border.width: 0; color: "#ececec"; Text { anchors.centerIn: parent; text: "ID"; font.bold: true } }
                            Rectangle { width: 300; height: parent.height; border.width: 0; color: "#ececec"; Text { anchors.centerIn: parent; text: "Key"; font.bold: true } }
                            Rectangle { width: 300; height: parent.height; border.width: 0; color: "#ececec"; Text { anchors.centerIn: parent; text: "Value"; font.bold: true } }
                            Rectangle { width: 90; height: parent.height; border.width: 0; color: "#ececec"; Text { anchors.centerIn: parent; text: "Edit"; font.bold: true } }
                            Rectangle { width: 90; height: parent.height; border.width: 0; color: "#ececec"; Text { anchors.centerIn: parent; text: "Delete"; font.bold: true } }
                        }
                    }

                    ListView {
                        id: itemsView
                        model: ListModel { id: itemsModel }
                        clip: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        delegate: Item {
                            width: tableContainer.width
                            height: 36

                            Rectangle {
                                anchors.fill: parent
                                color: index % 2 === 0 ? "#ffffff" : "#f5f5f5"
                            }

                            Row {
                                anchors.fill: parent
                                spacing: 0

                                Rectangle {
                                    width: 80
                                    height: 36
                                    border.width: 1
                                    border.color: "#d7d7d7"
                                    Text { anchors.centerIn: parent; text: model.id }
                                }
                                Rectangle {
                                    width: 300
                                    height: 36
                                    border.width: 1
                                    border.color: "#d7d7d7"
                                    Text {
                                        anchors.margins: 8
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: model.keyText
                                        elide: Text.ElideRight
                                        width: parent.width - 16
                                    }
                                }
                                Rectangle {
                                    width: 300
                                    height: 36
                                    border.width: 1
                                    border.color: "#d7d7d7"
                                    Text {
                                        anchors.margins: 8
                                        anchors.left: parent.left
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: model.valueText
                                        elide: Text.ElideRight
                                        width: parent.width - 16
                                    }
                                }
                                Rectangle {
                                    width: 90
                                    height: 36
                                    border.width: 1
                                    border.color: "#d7d7d7"
                                    Button {
                                        text: "Edit"
                                        anchors.centerIn: parent
                                        onClicked: {
                                            selectedItem = {
                                                id: model.id,
                                                keyText: model.keyText,
                                                valueText: model.valueText
                                            }
                                            editDialog.itemId = model.id
                                            editKey.text = model.keyText
                                            editValue.text = model.valueText
                                            editDialog.open()
                                        }
                                    }
                                }
                                Rectangle {
                                    width: 90
                                    height: 36
                                    border.width: 1
                                    border.color: "#d7d7d7"
                                    Button {
                                        text: "Delete"
                                        anchors.centerIn: parent
                                        onClicked: {
                                            selectedItem = {
                                                id: model.id,
                                                keyText: model.keyText,
                                                valueText: model.valueText
                                            }
                                            removeDialog.itemId = model.id
                                            removeDialog.open()
                                        }
                                    }
                                }
                            }
                        }

                        ScrollBar.vertical: ScrollBar {}
                    }
                }
            }

            Label {
                text: formController.statusMessage
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }

    Dialog {
        width: 420
        id: removeDialog
        title: "Delete entry"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.No
        property int itemId: -1

        contentItem: ColumnLayout {
            spacing: 12
            Layout.margins: 16
            Label {
                text: "Do you want to delete this key-value pair?"
                wrapMode: Text.WordWrap
            }
        }

        onAccepted: {
            if (itemId > 0) {
                formController.deleteEntry(itemId)
            }
        }
    }

    Dialog {
        id: editDialog
        title: "Edit entry"
        modal: true
        anchors.centerIn: parent
        width: 420
        standardButtons: Dialog.Cancel

        property int itemId: -1

        contentItem: ColumnLayout {
            spacing: 12
            Layout.margins: 16

            TextField {
                id: editKey
                placeholderText: "key"
                Layout.fillWidth: true
            }
            TextField {
                id: editValue
                placeholderText: "value"
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                Button {
                    text: "Cancel"
                    onClicked: editDialog.close()
                }

                Button {
                    text: "Save"
                    onClicked: {
                        if (editDialog.itemId > 0 && formController.updateEntry(editDialog.itemId, editKey.text, editValue.text)) {
                            editDialog.close()
                        }
                    }
                }
            }
        }

        onOpened: {
            if (selectedItem && selectedItem.id) {
                itemId = selectedItem.id
            }
        }
    }

    Connections {
        target: formController

        function onFormCleared() {
            if (!showListPage) {
                keyField.clear()
                valueField.clear()
            }
        }

        function onItemsChanged() {
            loadItemsToModel()
        }
    }
}
