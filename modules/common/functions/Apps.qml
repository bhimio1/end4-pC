pragma Singleton
import Quickshell
import qs
import qs.modules.common

/**
 * Launching the desktop's companion apps: Material 3 Settings (m3-settings)
 * for system settings and the Material 3 File Manager (m3fm) for folders.
 * Each falls back to something that is always there when the app isn't
 * installed. Commands come from Config.options.apps.
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
            `if command -v "$1" >/dev/null; then exec ${command} $2; else exec qs -p "$3" ipc call settings open; fi`,
            "bash", program, page ?? "", Quickshell.shellPath("")]);
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
            `${prelude ?? ""}
            if [ -n "$2" ] && command -v "$2" >/dev/null; then exec ${command} "$1"; else exec xdg-open "$1"; fi`,
            "bash", folder, program]);
    }
}
