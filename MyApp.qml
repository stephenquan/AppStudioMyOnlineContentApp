import QtQuick 2.7
import ArcGIS.AppFramework 1.0
import "MyOnlineContent"

App {
    id: app

    width: 800 * AppFramework.displayScaleFactor
    height: 640 * AppFramework.displayScaleFactor

    property bool loading: false

    property url portalUrl: "https://www.arcgis.com"
    property var portalInfo
    property url tokenServicesUrl
    property string username
    property string password
    property string networkErrorString: ""
    property var userInfo
    property var tokenInfo
    property string token: ""
    property real tokenExpires: 0
    property real currentTime: Date.now()
    property bool tokenValid: (token !== "" && tokenExpires > 0 && currentTime < tokenExpires)
    property string unexpiredToken: tokenValid ? token: ""
    property var content

    property string kPropUsername: "username"
    property string kPropPassword: "password"
    property string kPropToken: "token"
    property string kPropTokenExpires: "tokenExpires"

    MyOnlineContentApp {
        anchors.fill: parent
    }

    onUsernameChanged: setSetting(kPropUsername)
    onPasswordChanged: setSetting(kPropPassword) // should comment out
    onTokenChanged: setSetting(kPropToken)
    onTokenExpiresChanged: setSetting(kPropTokenExpires)

    function setSetting(key)
    {
        if (loading) return;
        app.settings.setValue(key, app[key]);
    }

    function loadSetting(key, defaultValue)
    {
        app[key] = app.settings.value(key) || defaultValue;
    }

    function submitNetworkRequest(networkRequest, params)
    {
        console.log(networkRequest.url + " " + JSON.stringify(params));

        networkErrorString = "";

        networkRequest.send( params );
    }

    function getNetworkResponse(networkRequest)
    {
        console.log(networkRequest.url, networkRequest.readyState);

        if (networkRequest.readyState !== NetworkRequest.ReadyStateComplete)
        {
            return null;
        }

        console.log(networkRequest.url, networkRequest.responseText);

        var json;
        try
        {
            json = JSON.parse(networkRequest.responseText);
        }
        catch (err)
        {
            networkErrorString = err.message;
            return null;
        }

        if (json.error)
        {
            if (json.error.code && json.error.messageCode && json.error.message)
            {
                networkErrorString = qsTr("ERROR %1 %2: %3")
                    .arg(json.error.code)
                    .arg(json.error.messageCode)
                    .arg(json.error.message);
                return null;
            }

            if (json.error.code && json.error.message && json.error.details)
            {
                networkErrorString = qsTr("ERROR %1 %2\n%3")
                    .arg(json.error.code)
                    .arg(json.error.message)
                    .arg(json.error.details.join("\n"));
                return null;
            }

            networkErrorString = JSON.stringify(json);
            return null;
        }

        return json;
    }

    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: currentTime = Date.now()
    }

    Component.onCompleted:
    {
        loading = true;
        // app.settings.remove(kPropPassword); // should uncomment
        loadSetting(kPropUsername, "");
        loadSetting(kPropPassword, "");
        loadSetting(kPropToken, "");
        loadSetting(kPropTokenExpires, 0);
        loading = false;
    }

}

