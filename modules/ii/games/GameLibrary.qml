import qs
import qs.services
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

/*
 * The game library overlay: recently played games, every game Material 3
 * Games knows about, and the way into Game Mode. Toggle it with
 * `qs ipc call games toggle` or the `quickshell:gamesToggle` global shortcut.
 */
Scope {
    id: root

    Loader {
        active: GlobalStates.gamesOpen

        sourceComponent: PanelWindow {
            id: panelWindow

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell:games"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Component.onCompleted: Games.rescan()

            // Dim the desktop; clicking outside the card closes the panel.
            Rectangle {
                anchors.fill: parent
                color: Appearance.m3colors.m3scrim
                opacity: 0.45
                MouseArea {
                    anchors.fill: parent
                    onClicked: GlobalStates.gamesOpen = false
                }
            }

            GameLibraryContent {
                anchors.centerIn: parent
                width: Math.min(parent.width - 80, 1180)
                height: Math.min(parent.height - 80, 760)
            }
        }
    }

    IpcHandler {
        target: "games"

        function toggle(): void { GlobalStates.gamesOpen = !GlobalStates.gamesOpen; }
        function open(): void { GlobalStates.gamesOpen = true; }
        function close(): void { GlobalStates.gamesOpen = false; }
        function gameMode(): void { Games.enterGameMode(); }
    }

    CompositorGlobalShortcut {
        name: "gamesToggle"
        description: "Toggle the game library"
        onPressed: GlobalStates.gamesOpen = !GlobalStates.gamesOpen
    }

    CompositorGlobalShortcut {
        name: "gameMode"
        description: "Enter Game Mode (gamescope, closes other apps)"
        onPressed: Games.enterGameMode()
    }
}
