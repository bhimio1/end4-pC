pragma ComponentBehavior: Bound
pragma Singleton
import qs.modules.common
import qs.modules.common.utils
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Controls
import Qt.labs.synchronizer
import Quickshell

Singleton {
    id: root

    enum Action {
        Copy,
        Edit,
        Search,
        CharRecognition,
        Record,
        RecordWithSound
    }

    property string imageSearchEngineBaseUrl: Config.options.search.imageSearch.imageSearchEngineBaseUrl
    property string fileUploadApiEndpoint: "https://uguu.se/upload"

    function getCommand(x, y, width, height, screenshotPath, action, saveDir = "", systemAudio = false, microphone = false) {
        // Set command for action
        const rx = Math.round(x);
        const ry = Math.round(y);
        const rw = Math.round(width);
        const rh = Math.round(height);
        const cropBase = `magick ${StringUtils.shellSingleQuoteEscape(screenshotPath)} `
            + `-crop ${rw}x${rh}+${rx}+${ry} +repage`
        const cropToStdout = `${cropBase} -`
        const cropInPlace = `${cropBase} '${StringUtils.shellSingleQuoteEscape(screenshotPath)}'`
        const cleanup = `rm '${StringUtils.shellSingleQuoteEscape(screenshotPath)}'`
        const slurpRegion = `${rx},${ry} ${rw}x${rh}`
        const uploadAndGetUrl = (filePath) => {
            return `curl -sF files[]=@'${StringUtils.shellSingleQuoteEscape(filePath)}' ${root.fileUploadApiEndpoint} | jq -r '.files[0].url'`
        }
        const audioFlags = (systemAudio ? " --sound" : "") + (microphone ? " --mic" : "")
        const annotationCommand = `${Config.options.regionSelector.annotation.useSatty ? "satty" : "swappy"} -f -`;
        const screenshotsApp = (Config.options.apps.screenshots ?? "").trim();
        // Runs `command` with $app set when Material 3 Screenshots is
        // installed, otherwise `fallback` (the shell's own handling).
        const withScreenshotsApp = (command, fallback) => `PATH="$HOME/.local/bin:$PATH"; `
            + `app='${StringUtils.shellSingleQuoteEscape(screenshotsApp)}'; `
            + `if command -v "$app" >/dev/null; then ${command}; else ${fallback}; fi`
        const copyFallback = (dir) => dir === ""
            ? `${cropToStdout} | wl-copy && ${cleanup}`
            : `mkdir -p '${StringUtils.shellSingleQuoteEscape(dir)}' && \
                    saveFileName="screenshot-$(date '+%Y-%m-%d_%H.%M.%S').png" && \
                    savePath="${dir}/$saveFileName" && \
                    ${cropToStdout} | tee >(wl-copy) > "$savePath" && \
                    ${cleanup}`
        switch (action) {
            case ScreenshotAction.Action.Copy:
                if (screenshotsApp !== "") {
                    // Material 3 Screenshots copies/saves by its own settings,
                    // shows a notification and keeps the capture in its history.
                    return ["bash", "-c", withScreenshotsApp(`${cropToStdout} | "$app" import -; ${cleanup}`, copyFallback(saveDir))]
                }
                return ["bash", "-c", copyFallback(saveDir)]
                break;
            case ScreenshotAction.Action.Edit:
                if (screenshotsApp !== "") {
                    return ["bash", "-c", withScreenshotsApp(`${cropToStdout} | "$app" import - --edit; ${cleanup}`, `${cropToStdout} | ${annotationCommand} && ${cleanup}`)]
                }
                return ["bash", "-c", `${cropToStdout} | ${annotationCommand} && ${cleanup}`]
                break;
            case ScreenshotAction.Action.Search:
                return ["bash", "-c", `${cropInPlace} && xdg-open "${root.imageSearchEngineBaseUrl}$(${uploadAndGetUrl(screenshotPath)})" && ${cleanup}`]
                break;
            case ScreenshotAction.Action.CharRecognition:
                return ["bash", "-c", `${cropInPlace} && tesseract '${StringUtils.shellSingleQuoteEscape(screenshotPath)}' stdout -l $(tesseract --list-langs | awk 'NR>1{print $1}' | tr '\\n' '+' | sed 's/\\+$/\\n/') | wl-copy && ${cleanup}`]
                break;
            case ScreenshotAction.Action.Record:
                return ["bash", "-c", `${Directories.recordScriptPath} --region '${slurpRegion}'${audioFlags}`]
                break;
            case ScreenshotAction.Action.RecordWithSound:
                return ["bash", "-c", `${Directories.recordScriptPath} --region '${slurpRegion}' --sound${microphone ? " --mic" : ""}`]
                break;
            default:
                console.warn("[Region Selector] Unknown snip action, skipping snip.");
                return;
        }
    }
}
