import QtQuick
import Quickshell.Io
import qs.modules.common.models.hyprland
import qs
import qs.services

QuickToggleModel {
    id: root
    name: Translation.tr("Game mode")
    toggled: !confOpt.value
    icon: "gamepad"

    mainAction: () => {
        root.toggled = !root.toggled;
        if (root.toggled) {
            HyprlandConfig.setMany({
                "animations:enabled": 0,
                "decoration:shadow:enabled": 0,
                "decoration:blur:enabled": 0,
                "general:gaps_in": 0,
                "general:gaps_out": 0,
                "general:border_size": 1,
                "decoration:rounding": 0,
                "general:allow_tearing": 1
            });
        } else {
            HyprlandConfig.resetMany([ //
                "animations:enabled", //
                "decoration:shadow:enabled", //
                "decoration:blur:enabled", //
                "general:gaps_in", //
                "general:gaps_out", //
                "general:border_size", //
                "decoration:rounding", //
                "general:allow_tearing", //
            ]);
        }
    }

    HyprlandConfigOption {
        id: confOpt
        key: "animations:enabled"
    }

    // Right-click opens the game library (Material 3 Games), where the full
    // Game Mode (gamescope, other apps closed) can be started.
    altAction: () => {
        GlobalStates.sidebarRightOpen = false;
        GlobalStates.gamesOpen = true;
    }

    tooltipText: Translation.tr("Game mode: lighter Hyprland effects. Right-click for the game library and full Game Mode")
}
