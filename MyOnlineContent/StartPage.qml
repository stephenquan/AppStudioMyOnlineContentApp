import QtQuick 2.9
import QtQuick.Controls 2.2
import ArcGIS.AppFramework 1.0

Item {

    Image {
        anchors.fill: parent

        source: "https://www.esri.com/content/dam/esrisites/en-us/landing-pages/industry/government/dutch-kadaster-case-study/dutch-kadaster-banner.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    Button {
        anchors.centerIn: parent

        text: "<< Start >>"
        font.pointSize: 20
        enabled: portalInfoRequest.canSubmit

        onClicked: submitPortalInfoRequest()
    }

    NetworkRequest {
        id: portalInfoRequest

        property bool busy: readyState === NetworkRequest.ReadyStateProcessing || readyState === NetworkRequest.ReadyStateSending
        property bool canSubmit: !busy

        url: "%1/sharing/rest/info".arg(app.portalUrl)

        onReadyStateChanged: handlePortalInfoResponse()
    }

    MyContentPage {
        id: myContentPage

        visible: false
    }

    function submitPortalInfoRequest() {
        submitNetworkRequest(portalInfoRequest, { f: "pjson" } );
    }

    function handlePortalInfoResponse() {
        app.portalInfo = getNetworkResponse(portalInfoRequest);
        if (!app.portalInfo) return;
        app.tokenServicesUrl = app.portalInfo.authInfo.tokenServicesUrl;
        stackView.push(myContentPage);
    }
}
