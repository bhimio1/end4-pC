pragma Singleton

import qs
import QtQuick
import Quickshell

Singleton {
    id: root

    function runSystemUpdate() {
        // paru is CachyOS's default helper, yay is common on Arch; plain
        // pacman when neither is installed.
        Quickshell.execDetached([
            "kitty", "--hold",
            "bash", "-c",
            "if command -v paru >/dev/null; then paru -Syu; elif command -v yay >/dev/null; then yay -Syu --combinedupgrade=false; else sudo pacman -Syu; fi"
        ])
        Qt.callLater(() => GlobalStates.settingsOpen = false)
    }

    function runUpdateDots() {
        const updateScript = `
            set -e
            DIR="$HOME/.config/quickshell"

            rm -rf "$DIR/end4-pC-tmp"
            git clone https://github.com/bhimio1/end4-pC.git "$DIR/end4-pC-tmp"

            rm -rf "$DIR/end4-pC-old"
            [ -d "$DIR/end4-pC" ] && mv "$DIR/end4-pC" "$DIR/end4-pC-old"
            mv "$DIR/end4-pC-tmp" "$DIR/end4-pC"

            killall qs 2>/dev/null || true
            sleep 0.5
            setsid qs -c end4-pC >/tmp/qs.log 2>&1 < /dev/null &
            disown

            rm -rf "$DIR/end4-pC-old"

            bash "$DIR/end4-pC/scripts/material-apps/install.sh" --update --force || true
        `

        Quickshell.execDetached(["kitty", "--hold", "bash", "-c", updateScript])
        Qt.callLater(() => GlobalStates.settingsOpen = false)
    }
}
