import QtQuick 2.7
import QtQuick.Controls 2.1

Item {
    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: StartPage { }
    }
}
