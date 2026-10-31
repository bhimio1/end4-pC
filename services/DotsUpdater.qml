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
        // This fork is retired: Material 3 Settings adds the same changes to
        // pctrade's end4-pC. "Update Dots" moves you over (once) and from
        // then on pctrade's own updater takes over.
        const updateScript = `
            set -e
            TMP="$(mktemp -d)"
            trap 'rm -rf "$TMP"' EXIT

            echo "end4-pC (bhimio1's fork) is retired; switching to pctrade's end4-pC"
            echo "with the Material 3 integration from Material 3 Settings."
            git clone --depth 1 https://github.com/bhimio1/end4-pC.git "$TMP/fork"
            bash "$TMP/fork/install.sh" --yes --only apps,shell
        `

        Quickshell.execDetached(["kitty", "--hold", "bash", "-c", updateScript])
        Qt.callLater(() => GlobalStates.settingsOpen = false)
    }
}
