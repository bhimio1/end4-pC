pragma Singleton

import qs.modules.common
import qs.modules.common.functions
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property string firstRunFilePath: `${Directories.state}/user/first_run.txt`
    property string firstRunFileContent: "This file is just here to confirm you've been greeted :>"
    property string firstRunNotifSummary: "Welcome!"
    property string firstRunNotifBody: "Hit Super+/ for a list of keybinds"
    property string defaultWallpaperPath: FileUtils.trimFileProtocol(`${Directories.assetsPath}/images/default_wallpaper.png`)
    property string welcomeQmlPath: FileUtils.trimFileProtocol(Quickshell.shellPath("welcome.qml"))
    // Material 3 Settings has a fuller welcome (wallpaper, apps, default apps,
    // keybinds) and keeps first_run.txt the same way welcome.qml does. Use it
    // when it's installed, welcome.qml otherwise.
    property string welcomeCommand: `PATH="$HOME/.local/bin:$PATH"; if command -v m3-settings >/dev/null; then exec m3-settings --welcome; else exec qs -p '${StringUtils.shellSingleQuoteEscape(root.welcomeQmlPath)}'; fi`

    function load() {
        firstRunFileView.reload()
    }

    function enableNextTime() {
        Quickshell.execDetached(["rm", "-f", root.firstRunFilePath])
    }
    function disableNextTime() {
        Quickshell.execDetached(["bash", "-c", `echo '${root.firstRunFileContent}' > '${root.firstRunFilePath}'`])
    }

    function handleFirstRun() {
        // Only a fresh setup gets the default wallpaper; someone who asked to
        // see the welcome again keeps theirs.
        if ((Config.options?.background?.wallpaperPath ?? "") === "")
            Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, root.defaultWallpaperPath])
        Quickshell.execDetached(["bash", "-c", root.welcomeCommand])
    }

    FileView {
        id: firstRunFileView
        path: Qt.resolvedUrl(firstRunFilePath)
        onLoadFailed: (error) => {
            if (error == FileViewError.FileNotFound) {
                firstRunFileView.setText(root.firstRunFileContent)
                root.handleFirstRun()
            }
        }
    }
}
