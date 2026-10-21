import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

RippleButton {
    id: button
    property string day
    property int isToday
    property bool bold
    /** Colors of the day's events from Material 3 Calendar, shown as dots. */
    property var eventColors: []

    Layout.fillWidth: false
    Layout.fillHeight: false
    implicitWidth: 38; 
    implicitHeight: 38;

    toggled: (isToday == 1)
    buttonRadius: Appearance.rounding.small
    
    contentItem: StyledText {
        anchors.fill: parent
        text: day
        horizontalAlignment: Text.AlignHCenter
        font.weight: bold ? Font.DemiBold : Font.Normal
        color: (isToday == 1) ? Appearance.m3colors.m3onPrimary : 
            (isToday == 0) ? Appearance.colors.colOnLayer1 : 
            Appearance.colors.colOutlineVariant

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        spacing: 2
        Repeater {
            model: button.eventColors
            delegate: Rectangle {
                required property string modelData
                width: 4
                height: 4
                radius: 2
                color: (button.isToday == 1) ? Appearance.m3colors.m3onPrimary
                    : (modelData !== "" ? modelData : Appearance.colors.colPrimary)
                opacity: (button.isToday == -1) ? 0.5 : 1
            }
        }
    }
}
