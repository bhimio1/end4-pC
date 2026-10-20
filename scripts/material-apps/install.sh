#!/usr/bin/env bash
# Installs, and keeps up to date, the Material 3 apps this shell uses:
#   m3fm         Material 3 File Manager
#   m3-settings  Material 3 Settings
#   m3-games     Material 3 Games
#   m3-browser   Material 3 Browser (needs Zen, LibreWolf or Firefox)
#
# Prebuilt binaries come from each project's latest GitHub release and go to
# ~/.local/bin, with desktop entries in ~/.local/share/applications. When a
# project has no release yet (or the machine isn't x86_64), it is built from
# source with cargo if available. Apps installed some other way (pacman, AUR,
# cargo install) are detected and left alone.
#
# Usage: install.sh [--update] [--force] [--quiet]
#   (default)  install the apps that are missing
#   --update   also update apps this script installed, when a newer release exists
#   --force    ignore the once-a-day limit on checks and retries
#   --quiet    no desktop notifications
set -uo pipefail

APPS=(
    # binary | GitHub repo | desktop id (= Wayland app id) | display name
    "m3fm|bhimio1/material-3-file-manager-rust|material_3_file_manager|Files"
    "m3-settings|bhimio1/material-3-settings|material_3_settings|Settings"
    "m3-games|bhimio1/material-3-games|material_3_games|Games"
    "m3-browser|bhimio1/material-3-browser|material_3_browser|Browser"
)

BIN_DIR="$HOME/.local/bin"
# Data files some apps keep next to the binary (`../share/<app>`).
SHARE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
DESKTOP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/quickshell/user/material-apps"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/material-apps"
DAY=$((24 * 60 * 60))

update=0 force=0 quiet=0
for arg in "$@"; do
    case "$arg" in
        --update) update=1 ;;
        --force) force=1 ;;
        --quiet) quiet=1 ;;
        -h | --help) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; exit 2 ;;
    esac
done

export PATH="$BIN_DIR:$PATH"
mkdir -p "$STATE_DIR" "$CACHE_DIR"

# One run at a time.
exec 9>"$STATE_DIR/lock"
flock -n 9 || exit 0

notify() {
    [[ $quiet -eq 1 ]] && return
    command -v notify-send >/dev/null && notify-send -a "Shell" -i system-software-install "$1" "$2"
}

# Seconds since the timestamp in file $1 was written (huge if missing).
age() {
    local stamp
    stamp=$(cat "$1" 2>/dev/null) || { echo 999999999; return; }
    echo $(($(date +%s) - stamp))
}

# Latest release tag of repo $1, or nothing.
latest_tag() {
    curl -fsSL --max-time 20 -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/$1/releases/latest" 2>/dev/null |
        jq -r '.tag_name // empty' 2>/dev/null
}

install_desktop_file() { # source-file desktop-id binary
    local target="$DESKTOP_DIR/$2.desktop"
    mkdir -p "$DESKTOP_DIR"
    # Point Exec at the binary we installed, in case ~/.local/bin isn't on
    # the PATH that launchers see.
    sed -E "s|^Exec=$3( \|$)|Exec=$BIN_DIR/$3\1|" "$1" > "$target"
    command -v update-desktop-database >/dev/null && update-desktop-database -q "$DESKTOP_DIR" 2>/dev/null
    return 0
}

install_release() { # binary repo desktop-id tag
    local bin=$1 repo=$2 id=$3 tag=$4
    local name="$bin-x86_64-linux"
    local url="https://github.com/$repo/releases/download/$tag/$name.tar.gz"
    local tmp
    tmp=$(mktemp -d) || return 1
    trap 'rm -rf "$tmp"' RETURN
    curl -fsSL --max-time 300 -o "$tmp/$name.tar.gz" "$url" || return 1
    if curl -fsSL --max-time 20 -o "$tmp/$name.tar.gz.sha256" "$url.sha256" 2>/dev/null; then
        (cd "$tmp" && sha256sum -c --quiet "$name.tar.gz.sha256") || { echo "Checksum mismatch for $url" >&2; return 1; }
    fi
    tar -xzf "$tmp/$name.tar.gz" -C "$tmp" || return 1
    install -Dm755 "$tmp/$name/$bin" "$BIN_DIR/$bin" || return 1
    [[ -f "$tmp/$name/$id.desktop" ]] && install_desktop_file "$tmp/$name/$id.desktop" "$id" "$bin"
    if [[ -d "$tmp/$name/share" ]]; then
        mkdir -p "$SHARE_DIR" && cp -r "$tmp/$name/share/." "$SHARE_DIR/" || return 1
    fi
    echo "$tag" > "$STATE_DIR/$bin.version"
}

install_source() { # binary repo desktop-id
    local bin=$1 repo=$2 id=$3
    command -v cargo >/dev/null && command -v git >/dev/null || return 1
    local src="$CACHE_DIR/$bin-src"
    rm -rf "$src"
    git clone -q --depth 1 "https://github.com/$repo.git" "$src" || return 1
    [[ -f "$src/Cargo.toml" ]] || return 1
    (cd "$src" && cargo build -q --release --locked) || return 1
    install -Dm755 "$src/target/release/$bin" "$BIN_DIR/$bin" || return 1
    [[ -f "$src/packaging/$id.desktop" ]] && install_desktop_file "$src/packaging/$id.desktop" "$id" "$bin"
    # Material 3 Browser also needs its extension built (unsigned from source).
    if [[ -f "$src/extension/stage.mjs" ]]; then
        command -v npm >/dev/null || return 1
        (cd "$src/extension" && npm ci --silent && node stage.mjs) >/dev/null 2>&1 || return 1
        mkdir -p "$SHARE_DIR/$bin" || return 1
        cp "$src/extension/stage/material-3-browser.xpi" "$SHARE_DIR/$bin/" || return 1
        rm -rf "$SHARE_DIR/$bin/extension" && cp -r "$src/extension/stage/extension" "$SHARE_DIR/$bin/extension" || return 1
    fi
    echo "source-$(git -C "$src" rev-parse --short HEAD)" > "$STATE_DIR/$bin.version"
    rm -rf "$src"
}

installed=() updated=() failed=()
for entry in "${APPS[@]}"; do
    IFS='|' read -r bin repo id name <<<"$entry"
    managed=0
    [[ -f "$STATE_DIR/$bin.version" && -x "$BIN_DIR/$bin" ]] && managed=1

    if [[ $managed -eq 0 ]] && command -v "$bin" >/dev/null; then
        continue # installed some other way
    fi
    if [[ $managed -eq 1 && ( $update -eq 0 || ( $force -eq 0 && $(age "$STATE_DIR/$bin.checked") -lt $DAY ) ) ]]; then
        continue
    fi
    # Don't retry a failed install on every login.
    if [[ $force -eq 0 && $(age "$STATE_DIR/$bin.failed") -lt $DAY ]]; then
        continue
    fi

    # A project with nothing published yet (or no network) isn't a failure.
    if [[ $managed -eq 0 && -z "$(GIT_TERMINAL_PROMPT=0 git ls-remote -q "https://github.com/$repo.git" HEAD 2>/dev/null)" ]]; then
        continue
    fi

    tag=""
    [[ "$(uname -m)" == "x86_64" ]] && tag=$(latest_tag "$repo")
    date +%s > "$STATE_DIR/$bin.checked"

    if [[ $managed -eq 1 ]]; then
        current=$(cat "$STATE_DIR/$bin.version")
        [[ -z "$tag" || "$tag" == "$current" ]] && continue
        if install_release "$bin" "$repo" "$id" "$tag"; then
            updated+=("$name $tag")
        fi
        continue
    fi

    if [[ ${#installed[@]} -eq 0 && ${#failed[@]} -eq 0 ]]; then
        if [[ -n "$tag" ]]; then
            notify "Installing Material 3 apps" "Downloading $name…"
        else
            notify "Installing Material 3 apps" "Building $name from source. This takes a few minutes."
        fi
    fi
    if { [[ -n "$tag" ]] && install_release "$bin" "$repo" "$id" "$tag"; } || install_source "$bin" "$repo" "$id"; then
        installed+=("$name")
        rm -f "$STATE_DIR/$bin.failed"
    else
        failed+=("$name")
        date +%s > "$STATE_DIR/$bin.failed"
    fi
done

join() { local IFS=","; echo "$*" | sed 's/,/, /g'; }
[[ ${#installed[@]} -gt 0 ]] && notify "Material 3 apps installed" "$(join "${installed[@]}") ready."
[[ ${#updated[@]} -gt 0 ]] && notify "Material 3 apps updated" "$(join "${updated[@]}")"
if [[ ${#failed[@]} -gt 0 ]]; then
    notify "Couldn't install $(join "${failed[@]}")" "No release was available and building from source needs cargo and git. Install them, then press Material 3 apps in the shell settings' About page."
    exit 1
fi
exit 0
