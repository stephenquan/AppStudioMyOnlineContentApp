import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import ArcGIS.AppFramework 1.0

Page {
    id: page

    header: ToolBar {
        RowLayout {
            width: parent.width

            Item {
                Layout.fillWidth: true
            }

            ToolButton {
                id: menuButton
                text: qsTr("Menu")
                font.pointSize: 12

                onClicked: popup.open()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        ListView {
            id: listView

            Layout.fillHeight: true
            Layout.fillWidth: true

            model: app.tokenValid && app.content && app.content.items ? app.content.items : 0
            clip: true

            delegate: RowLayout {
                width: listView.width

                ItemDelegate {
                    text: index + 1
                    font.pointSize: 12
                }

                ItemDelegate {
                    text: modelData.title
                    font.pointSize: 12
                }

                Item {
                    Layout.fillWidth: true
                }

                ItemDelegate {
                    text: modelData.type || ""
                    font.pointSize: 12
                }
            }
        }

        Text {
            Layout.fillWidth: true

            text: networkErrorString
            font.pointSize: 12
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }
    }

    footer: Text {
        text: tokenValid ?
                  qsTr("You're signed in and can see your ArcGIS Online content. You will not need to sign in again until: %1").arg(new Date(tokenExpires)) :
                  qsTr("Please sign in to view your ArcGIS Online content.")
        font.pointSize: 10
        font.italic: true
        color: "grey"
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    }

    Menu {
        id: popup

        x: page.width - popup.width
        y: 0

        MenuItem {
            text: qsTr("Sign in")
            font.pointSize: 12
            enabled: !app.tokenValid

            onTriggered: stackView.push(userPageComponent)
        }

        MenuItem {
            text: qsTr("Sign out")
            font.pointSize: 12
            enabled: app.tokenValid

            onTriggered: logout()
        }

        MenuItem {
            text: qsTr("Refresh")
            font.pointSize: 12
            enabled: contentRequest.canSubmit

            onTriggered: submitContentRequest()
        }
    }

    NetworkRequest {
        id: contentRequest

        property bool busy: readyState === NetworkRequest.ReadyStateProcessing || readyState === NetworkRequest.ReadyStateSending
        property bool canSubmit: !busy && tokenValid

        url: "%1/sharing/rest/content/users/%2".arg(app.portalUrl).arg(app.username)

        onReadyStateChanged: handleContentResponse()
    }

    Component {
        id: userPageComponent

        UserPage {
        }
    }

    Component.onCompleted: submitContentRequest()

    Connections {
        target: app

        onTokenValidChanged: {
            console.log("tokenValid: ", app.tokenValid);
            if (!app.tokenValid) return;
            submitContentRequest();
        }
    }

    function logout() {
        app.token = "";
        app.tokenExpires = 0;
    }

    function submitContentRequest() {
        if (!contentRequest.canSubmit) return;

        app.content = null;

        var params = {
            token: app.token,
            f: "pjson"
        };

        submitNetworkRequest(contentRequest, params)
    }

    function handleContentResponse() {
        app.content = getNetworkResponse(contentRequest);
        if (!app.content) return;
    }
}
