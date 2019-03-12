import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ArcGIS.AppFramework 1.0

Page {
    property bool passwordValid: app.password !== ""

    header: ToolBar {
        RowLayout {
            width: parent.width

            Item {
                Layout.fillWidth: true
            }

            ToolButton {
                text: "X"
                font.pointSize: 14

                onClicked: {
                    networkErrorString = "";
                    stackView.pop();
                    stackView.pop();
                }
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

            RowLayout {
                Layout.fillWidth: true

                Button {
                    text: qsTr("<- Back")
                    font.pointSize: 12

                    onClicked: {
                        networkErrorString = "";
                        stackView.pop();
                    }
                }

                Text {
                    text: app.username
                    font.pointSize: 12
                }
            }

            Text {
                text: qsTr("Enter password")
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

                text: app.password
                font.pointSize: 12
                focus: true
                echoMode: TextInput.Password

                onTextChanged: app.password = text

                onAccepted: submitTokenInfoRequest()
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
                    text: qsTr("Sign in")
                    font.pointSize: 12
                    enabled: tokenInfoRequest.canSubmit

                    onClicked: submitTokenInfoRequest()
                }
            }

        }
    }

    NetworkRequest {
        id: tokenInfoRequest

        property bool busy: readyState === NetworkRequest.ReadyStateProcessing || readyState === NetworkRequest.ReadyStateSending
        property bool canSubmit: !busy && passwordValid

        method: "POST"
        url: app.tokenServicesUrl
        uploadPrefix: "!@#$"

        onReadyStateChanged: handleTokenInfoResponse()
    }

    function submitTokenInfoRequest() {
        if (!tokenInfoRequest.canSubmit) return;

        app.token = "";
        app.tokenExpires = 0;

        var params = {
            username: app.username,
            password: app.password,
            referer: app.portalUrl,
            f: "pjson"
        };

        submitNetworkRequest(tokenInfoRequest, params);
    }

    function handleTokenInfoResponse() {
        app.tokenInfo = getNetworkResponse(tokenInfoRequest);
        if (!app.tokenInfo) return;
        console.log(JSON.stringify(app.tokenInfo));
        app.tokenExpires = app.tokenInfo.expires;
        app.token = app.tokenInfo.token;
        stackView.pop();
        stackView.pop();
    }


}
