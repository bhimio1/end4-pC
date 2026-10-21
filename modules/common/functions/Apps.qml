pragma Singleton
import Quickshell
import qs
import qs.modules.common

/**
 * Launching the desktop's companion Material 3 apps: Settings (m3-settings),
 * File Manager (m3fm), Music (m3-music), AI (m3-ai), Games (m3-games) and
 * Browser (m3-browser). Settings and the file manager fall back to something
 * that is always there when they aren't installed; their commands come from
 * Config.options.apps. ~/.local/bin is put on PATH because that's where
 * scripts/material-apps/install.sh puts them.
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
     * it isn't installed yet, offers the installer instead.
     * @param {string} program e.g. "m3-music"
     * @param {list<string>} args
     */
    function open(program, args) {
        Quickshell.execDetached(["bash", "-c",
            `PATH="$HOME/.local/bin:$PATH"
            if command -v "$1" >/dev/null; then shift; exec "$@"; fi
            notify-send -a Shell "$2 isn't installed yet" "Install it from the shell settings: About → Material 3 apps."`,
            "bash", program, program].concat(args ?? []));
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
