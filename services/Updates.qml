pragma Singleton
import qs
import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io

/*
 * System updates service. Currently only supports Arch.
 */
Singleton {
    id: root

    property bool available: false
    property alias checking: checkUpdatesProc.running
    property int count: 0
    
    readonly property bool updateAdvised: available && count > Config.options.updates.adviseUpdateThreshold
    readonly property bool updateStronglyAdvised: available && count > Config.options.updates.stronglyAdviseUpdateThreshold

    function load() {}
    function refresh() {
        if (!available) return;
        print("[Updates] Checking for system updates")
        checkUpdatesProc.running = true;
    }

    Timer {
        interval: Config.options.updates.checkInterval * 60 * 1000
        repeat: true
        running: Config.ready && Config.options.updates.enableCheck
        onTriggered: {
            print("[Updates] Periodic update check due")
            root.refresh();
        }
    }

    Process {
        id: checkAvailabilityProc
        running: Config.ready && Config.options.updates.enableCheck
        command: ["which", "checkupdates"]
        onExited: (exitCode, exitStatus) => {
            root.available = (exitCode === 0);
            firstCheckTimer.start();
        }
    }

    Timer {
        id: firstCheckTimer
        interval: 60 * 1000
        onTriggered: root.refresh()
    }

    Process {
        id: checkUpdatesProc
        // `cmd | wc -l` always succeeds, so pick the helper first (paru is
        // CachyOS's default) instead of chaining with ||.
        command: ["bash", "-c", "pacman=$(checkupdates 2>/dev/null | wc -l); if command -v paru >/dev/null; then aur=$(paru -Qua 2>/dev/null | wc -l); elif command -v yay >/dev/null; then aur=$(yay -Qua 2>/dev/null | wc -l); else aur=0; fi; echo $((pacman + aur))"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.count = parseInt(text.trim())
            }
        }
    }
}
