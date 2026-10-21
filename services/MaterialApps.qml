pragma Singleton
import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

/*
 * Installs and updates the essential Material 3 apps (Settings, Files,
 * Screenshots) with scripts/material-apps/install.sh. Optional apps are
 * installed from Settings' "Material 3 apps" page (Apps.manage()).
 * Runs once at startup unless apps.autoInstallMaterialApps is off; the script itself limits release
 * checks and retries to once a day.
 */
Singleton {
    id: root

    property alias running: installer.running
    property bool startupDone: false

    function load() {}

    /**
     * @param {boolean} force skip the once-a-day limit (for the manual button)
     */
    function run(force) {
        if (installer.running) return;
        const args = ["bash", Quickshell.shellPath("scripts/material-apps/install.sh"), "--update"];
        if (force) args.push("--force");
        installer.command = args;
        installer.running = true;
    }

    // Give the session a moment to settle before downloading anything.
    Timer {
        interval: 15 * 1000
        running: Config.ready && !root.startupDone
        onTriggered: {
            root.startupDone = true;
            if (Config.options.apps.autoInstallMaterialApps ?? true) root.run(false);
        }
    }

    Process {
        id: installer
        stderr: StdioCollector {
            onStreamFinished: if (text.trim() !== "") print("[MaterialApps] " + text.trim())
        }
    }
}
