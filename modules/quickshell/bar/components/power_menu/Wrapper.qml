import QtQuick
import Quickshell

Item {
    id: root
    required property ShellScreen screen
    required property bool visibility

    visible: width > 0

    states: [
        State {
            name: "hidden"
            when: !root.visibility
            PropertyChanges {
                target: root
                implicitWidth: 0
                implicitHeight: 0
                opacity: 0
            }
        },
        State {
            name: "visible"
            when: root.visibility
            PropertyChanges {
                target: root
                implicitWidth: 60
                implicitHeight: 180
                opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"
            to: "visible"
            reversible: true
            NumberAnimation {
                target: root
                properties: "implicitWidth,implicitHeight,opacity"
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }
    ]

    Content {
        id: content
    }
}
