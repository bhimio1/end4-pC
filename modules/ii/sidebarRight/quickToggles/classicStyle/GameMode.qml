import qs.modules.common
import qs.modules.common.models.quickToggles
import qs.modules.common.widgets
import qs.services
import Quickshell

// Shares GameModeToggle with the Android-style panel: it writes Hyprland's
// shell overrides (which works with Lua configs, where `hyprctl keyword` is
// ignored) and right-click opens the game library.
QuickToggleButton {
    id: root
    readonly property GameModeToggle model: GameModeToggle {}
    buttonIcon: model.icon
    toggled: model.toggled
    onClicked: model.mainAction()
    altAction: model.altAction

    StyledToolTip {
        text: Translation.tr("Game mode | Right-click for the game library")
    }
}
