pragma Singleton
import Quickshell
import qs
import qs.modules.common

/**
 * Launching the desktop's companion Material 3 apps. The essential ones
 * (Settings, Files, Screenshots) are installed by
 * scripts/material-apps/install.sh; the optional ones (Music, Games, Browser,
 * AI, Viewer, Text, Monitor, Calendar) from Settings' "Material 3 apps" page.
 * Settings and the file manager fall back to something that is always there
 * when they aren't installed; their commands come from Config.options.apps.
 * ~/.local/bin is put on PATH because that's where both installers put them.
 */
Singleton {
    id: root

    /**
     * Opens Material 3 Settings, optionally on a page (e.g. "network",
     * "bluetooth", "packages", "end4"). Falls back to the shell's own settings
     * when it isn't installed or apps.settings is empty.
     * @param {string} page
     */
    function openSystemSettings(page) {
        const command = (Config.options.apps.settings ?? "").trim();
        if (command === "") {
            GlobalStates.settingsOpen = true;
            return;
        }
        const program = command.split(/\s+/)[0];
        Quickshell.execDetached(["bash", "-c",
            `PATH="$HOME/.local/bin:$PATH"; if command -v "$1" >/dev/null; then exec ${command} $2; else exec qs -p "$3" ipc call settings open; fi`,
            "bash", program, page ?? "", Quickshell.shellPath("")]);
    }

    /**
     * Starts one of the Material 3 apps by binary name, with arguments. When
     * it isn't installed yet, opens its page in Settings, where it can be
     * installed (or says how to get Settings when that is missing too).
     * @param {string} program e.g. "m3-music"
     * @param {list<string>} args
     */
    function open(program, args) {
        Quickshell.execDetached(["bash", "-c",
            `PATH="$HOME/.local/bin:$PATH"
            if command -v "$1" >/dev/null; then shift; exec "$@"; fi
            if command -v m3-settings >/dev/null; then exec m3-settings material-apps "$1"; fi
            notify-send -a Shell "$1 isn't installed yet" "Optional apps are installed from Material 3 Settings, which the shell installs. Press Material 3 apps in the shell settings' About page to install it now."`,
            "bash", program].concat([program]).concat(args ?? []));
    }

    /**
     * Opens Settings' "Material 3 apps" page, optionally on one app.
     * @param {string} program e.g. "m3-music", or "" for the whole page
     */
    function manage(program) {
        root.openSystemSettings(program ? `material-apps ${program}` : "material-apps");
    }

    /**
     * Opens a folder in the configured file manager, or with xdg-open when it
     * isn't installed. The path is passed as an argument, never interpolated.
     * @param {string} path folder path or file:// url
     * @param {string} prelude optional bash run first (e.g. mkdir)
     */
    function openFolder(path, prelude) {
        const folder = FileUtils.trimFileProtocol(path ?? "");
        const command = Config.options.apps.fileManager ?? "m3fm";
        const program = command.trim().split(/\s+/)[0];
        Quickshell.execDetached(["bash", "-c",
            `PATH="$HOME/.local/bin:$PATH"
            ${prelude ?? ""}
            if [ -n "$2" ] && command -v "$2" >/dev/null; then exec ${command} "$1"; else exec xdg-open "$1"; fi`,
            "bash", folder, program]);
    }
}
