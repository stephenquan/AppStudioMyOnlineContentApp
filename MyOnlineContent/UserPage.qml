import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ArcGIS.AppFramework 1.0

Page {
    property bool usernameValid: app.username !== ""

    header: ToolBar {
        RowLayout {
            width: parent.width

            Item {
                Layout.fillWidth: true
            }

            ToolButton {
                text: qsTr("Close")
                font.pointSize: 14

                onClicked: stackView.pop()
            }
        }
    }

    Image {
        anchors.fill: parent

        source: "https://www.esri.com/content/dam/esrisites/en-us/landing-pages/industry/government/dutch-kadaster-case-study/dutch-kadaster-banner.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    Rectangle {
        anchors.centerIn: parent

        width: Math.min(parent.width - 20, 400 * AppFramework.displayScaleFactor)
        height: Math.min(parent.height - 20, 350 * AppFramework.displayScaleFactor)

        color: "white"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20 * AppFramework.displayScaleFactor

            spacing: 15 * AppFramework.displayScaleFactor

            Image {
                Layout.preferredWidth: 85 * AppFramework.displayScaleFactor
                Layout.preferredHeight: 45 * AppFramework.displayScaleFactor

                source: "https://www.arcgis.com/img/logo-esri.png"
                fillMode: Image.PreserveAspectFit
            }

            Text {
                text: qsTr("Sign In")
                font.pointSize: 14
            }

            Text {
                Layout.fillWidth: true

                wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                visible: networkErrorString !== ""
                text: networkErrorString
                font.pointSize: 12
                color: "red"
            }

            TextField {
                Layout.fillWidth: true

                text: app.username
                font.pointSize: 12
                focus: true
                placeholderText: qsTr("Username")

                onTextChanged: {
                    networkErrorString = "";
                    app.username = text;
                }

                onAccepted: submitUserInfoRequest()
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                }

                Button {
                    text: qsTr("Next >")
                    font.pointSize: 12
                    enabled: userInfoRequest.canSubmit

                    onClicked: submitUserInfoRequest()
                }

            }
        }
    }

    NetworkRequest {
        id: userInfoRequest

        property bool busy: readyState === NetworkRequest.ReadyStateProcessing || readyState === NetworkRequest.ReadyStateSending
        property bool canSubmit: usernameValid && !busy

        url: "https://www.arcgis.com/sharing/rest/community/users/%1".arg(app.username)

        onReadyStateChanged: handleUserInfoResponse()
    }

    function submitUserInfoRequest() {
        submitNetworkRequest(userInfoRequest, { f: "pjson" } );
    }

    function handleUserInfoResponse() {
        app.userInfo = getNetworkResponse(userInfoRequest);
        if (!app.userInfo) return;
        stackView.push(passwordPageComponent)
    }

    Component {
        id: passwordPageComponent

        PasswordPage {
        }
    }

}
