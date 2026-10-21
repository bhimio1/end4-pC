#!/usr/bin/env bash
# Installs end4-pC and everything that comes with it, asking before each part:
#
#   shell         clone (or update) end4-pC into ~/.config/quickshell/end4-pC
#   apps          the essential Material 3 apps (Settings, Files, Screenshots)
#   default       make end4-pC the shell Hyprland starts (instead of ii)
#   keybinds      add the suggested keybinds that are still free
#   plymouth      the boot animation, in your colors
#   sddm          the end4-material login screen
#
# It needs illogical-impulse (end-4's dots-hyprland) installed. The system
# parts (Plymouth, SDDM) ask for your password once, through sudo.
#
# Usage: install.sh [--yes] [--only PARTS] [--skip PARTS] [--dir DIR]
#   --yes          don't ask; install every part (that applies)
#   --only PARTS   just these parts, comma-separated (e.g. plymouth,sddm)
#   --skip PARTS   everything except these parts
#   --dir DIR      where end4-pC lives (default ~/.config/quickshell/end4-pC)
#   --no-restart   don't restart the shell at the end
#
# Run it again any time: every part is safe to repeat, and it's how you
# refresh the boot animation's colors after changing wallpaper.
set -uo pipefail

REPO_URL="https://github.com/bhimio1/end4-pC.git"
PARTS=(shell apps default keybinds plymouth sddm)
DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/end4-pC"
HYPR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
yes=0 restart=1 only="" skip=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y | --yes) yes=1 ;;
        --only) only="$2"; shift ;;
        --skip) skip="$2"; shift ;;
        --dir) DIR="$2"; shift ;;
        --no-restart) restart=0 ;;
        -h | --help) sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 2 ;;
    esac
    shift
done
for p in ${only//,/ } ${skip//,/ }; do
    [[ " ${PARTS[*]} " == *" $p "* ]] || { echo "Unknown part: $p (parts: ${PARTS[*]})" >&2; exit 2; }
done
if [[ $EUID -eq 0 ]]; then
    echo "Run this as yourself, not as root; it asks for your password when it needs it." >&2
    exit 1
fi

bold=$'\e[1m' dim=$'\e[2m' green=$'\e[32m' yellow=$'\e[33m' red=$'\e[31m' reset=$'\e[0m'
[[ -t 1 ]] || bold="" dim="" green="" yellow="" red="" reset=""
step() { printf '\n%s==>%s %s%s%s\n' "$green" "$reset" "$bold" "$*" "$reset"; }
note() { printf '    %s\n' "$*"; }
warn() { printf '    %s%s%s\n' "$yellow" "$*" "$reset"; }
fail() { printf '    %s%s%s\n' "$red" "$*" "$reset"; }

wanted() { # is this part selected by --only/--skip?
    [[ -n "$only" && ",$only," != *",$1,"* ]] && return 1
    [[ ",$skip," == *",$1,"* ]] && return 1
    return 0
}
# ask "question" → 0 for yes. Defaults to yes; --yes or no terminal answers yes.
ask() {
    [[ $yes -eq 1 || ! -t 0 ]] && return 0
    local reply
    read -r -p "    $1 [Y/n] " reply
    [[ -z "$reply" || "$reply" == [Yy]* ]]
}

declare -A result
done_part() { result[$1]="$2"; }

# --- Checks -----------------------------------------------------------------

step "Checking your setup"
if [[ ! -d "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/ii" ]]; then
    warn "illogical-impulse (~/.config/quickshell/ii) wasn't found. end4-pC needs it:"
    warn "https://github.com/end-4/dots-hyprland"
    ask "Continue anyway?" || exit 1
else
    note "illogical-impulse found."
fi
for cmd in git qs; do
    command -v "$cmd" >/dev/null || warn "$cmd isn't installed; it's needed."
done

# --- Shell ------------------------------------------------------------------

if wanted shell; then
    step "end4-pC"
    # Running from a checkout elsewhere: use that one if it is the target.
    here="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"
    if [[ -d "$DIR/.git" ]]; then
        if [[ -n "$(git -C "$DIR" status --porcelain --untracked-files=no 2>/dev/null)" ]]; then
            warn "$DIR has local changes; not updating it."
            done_part shell "kept (local changes)"
        elif git -C "$DIR" pull --ff-only -q; then
            note "Updated $DIR."
            done_part shell "updated"
        else
            warn "Couldn't update $DIR (offline, or the branch has diverged); using it as it is."
            done_part shell "kept"
        fi
    elif [[ -e "$DIR" ]]; then
        fail "$DIR exists but isn't a git checkout; move it away and run this again."
        exit 1
    elif [[ -n "$here" && -f "$here/shell.qml" && -d "$here/.git" ]] && ask "Copy this checkout ($here) to $DIR?"; then
        mkdir -p "$(dirname "$DIR")"
        git clone -q "$here" "$DIR" && git -C "$DIR" remote set-url origin "$REPO_URL"
        done_part shell "installed"
    else
        mkdir -p "$(dirname "$DIR")"
        git clone -q "$REPO_URL" "$DIR" || { fail "Cloning $REPO_URL failed."; exit 1; }
        note "Installed to $DIR."
        done_part shell "installed"
    fi
fi
if [[ ! -f "$DIR/shell.qml" ]]; then
    fail "end4-pC isn't in $DIR; run without --skip shell first."
    exit 1
fi

# --- Material 3 apps --------------------------------------------------------

if wanted apps; then
    step "Material 3 apps (Settings, Files, Screenshots)"
    note "Prebuilt from GitHub releases into ~/.local/bin, or built with cargo when there's no release."
    if ask "Install or update them now?"; then
        if bash "$DIR/scripts/material-apps/install.sh" --update --force --quiet; then
            done_part apps "installed"
        else
            warn "Some apps couldn't be installed; the shell retries about 15 seconds after it starts."
            done_part apps "partly installed"
        fi
        note "The optional apps (Music, Games, Calendar, …) are in Settings → Material 3 apps."
    else
        done_part apps "skipped (the shell installs them when it starts)"
    fi
fi

# --- Default shell ----------------------------------------------------------

if wanted default; then
    step "Default shell"
    vars="$HYPR_DIR/hyprland/variables.lua"
    if [[ ! -f "$vars" ]]; then
        warn "$vars wasn't found; set qsConfig to \"end4-pC\" by hand."
        done_part default "not found"
    elif grep -Eq 'hl\.env\(\s*"qsConfig"\s*,\s*"end4-pC"\s*\)' "$vars"; then
        note "Hyprland already starts end4-pC."
        done_part default "already set"
    elif ! grep -Eq 'hl\.env\(\s*"qsConfig"\s*,\s*"[^"]*"\s*\)' "$vars"; then
        warn "No qsConfig line in $vars; add: hl.env(\"qsConfig\", \"end4-pC\")"
        done_part default "not changed"
    elif ask "Start end4-pC instead of ii when Hyprland starts?"; then
        cp -p "$vars" "$vars.end4-pC.bak"
        sed -E -i 's/(hl\.env\(\s*"qsConfig"\s*,\s*)"[^"]*"/\1"end4-pC"/' "$vars"
        note "Done (backup: $vars.end4-pC.bak)."
        done_part default "set"
    else
        done_part default "skipped"
    fi
fi

# --- Keybinds ---------------------------------------------------------------

# key | dispatcher | description
KEYBINDS=(
    'SUPER + escape|hl.dsp.global("quickshell:settingsToggle")|Toggle shell settings'
    'SUPER + I|hl.dsp.exec_cmd("m3-settings")|System settings'
    'SUPER + E|hl.dsp.exec_cmd("m3fm")|Files'
    'Print|hl.dsp.exec_cmd("m3-screenshots output --active")|Screenshot of this screen'
    'SUPER + Print|hl.dsp.exec_cmd("m3-screenshots window --active")|Screenshot of this window'
    'SUPER + SHIFT + R|hl.dsp.exec_cmd("m3-screenshots record region --toggle")|Record a region (again to stop)'
    'SUPER + G|hl.dsp.global("quickshell:gamesToggle")|Game library'
    'SUPER + SHIFT + G|hl.dsp.global("quickshell:gameMode")|Game Mode'
)
# Is this key already bound anywhere in the Hyprland config (outside our block)?
key_taken() {
    local key="$1" norm
    norm="$(tr -d ' ' <<<"$key" | tr '[:lower:]' '[:upper:]')"
    grep -rhs --include='*.lua' --include='*.conf' -v 'end4-pC keybind' "$HYPR_DIR" |
        sed -n -E 's/.*hl\.bind\(\s*"([^"]*)".*/\1/p; s/^\s*bind[a-z]*\s*=\s*([^,]*),([^,]*),.*/\1+\2/p' |
        tr -d ' ' | tr '[:lower:]' '[:upper:]' | sed 's/^+//' | grep -qxF "$norm"
}

if wanted keybinds; then
    step "Keybinds"
    custom="$HYPR_DIR/custom/keybinds.lua"
    if [[ ! -d "$HYPR_DIR" ]]; then
        warn "$HYPR_DIR wasn't found; see the README for the keybinds."
        done_part keybinds "not found"
    else
        new=() taken=()
        for kb in "${KEYBINDS[@]}"; do
            IFS='|' read -r key dsp desc <<<"$kb"
            if grep -qsF "\"$key\", $dsp" "$custom"; then
                continue # added before
            elif key_taken "$key"; then
                taken+=("$key ($desc)")
            else
                new+=("hl.bind(\"$key\", $dsp, {description = \"$desc\"}) -- end4-pC keybind")
            fi
        done
        if [[ ${#new[@]} -eq 0 ]]; then
            note "Nothing to add."
            done_part keybinds "nothing new"
        else
            for line in "${new[@]}"; do note "${dim}${line% -- *}${reset}"; done
            if ask "Add these to $custom?"; then
                mkdir -p "$(dirname "$custom")"
                [[ -f "$custom" ]] && cp -p "$custom" "$custom.end4-pC.bak"
                printf '%s\n' "${new[@]}" >>"$custom"
                done_part keybinds "added ${#new[@]}"
            else
                done_part keybinds "skipped"
            fi
        fi
        for t in "${taken[@]}"; do warn "Already bound in your config, left alone: $t"; done
    fi
fi

# --- System parts (one password prompt) -------------------------------------

want_plymouth=0 want_sddm=0
if wanted plymouth; then
    step "Boot animation (Plymouth)"
    note "The illogical-impulse emblem, drawn in your current colors. Rebuilds the initramfs."
    if ! command -v plymouth-set-default-theme >/dev/null; then
        warn "Plymouth isn't installed."
        if command -v pacman >/dev/null && ask "Install plymouth with pacman and set up the boot animation?"; then
            want_plymouth=2
        else
            done_part plymouth "skipped (plymouth not installed)"
        fi
    elif ask "Install the boot animation?"; then
        want_plymouth=1
    else
        done_part plymouth "skipped"
    fi
fi
if wanted sddm; then
    step "Login screen (SDDM)"
    note "end4-material: looks like the lock screen, with your wallpaper and colors."
    dm=""
    [[ -L /etc/systemd/system/display-manager.service ]] &&
        dm="$(basename "$(readlink -f /etc/systemd/system/display-manager.service)" .service)"
    if ! command -v sddm >/dev/null; then
        note "SDDM isn't installed${dm:+ (your login manager is $dm)}; skipping."
        done_part sddm "skipped (SDDM not installed)"
    else
        [[ -n "$dm" && "$dm" != sddm ]] && warn "SDDM is installed but your login manager is $dm; the theme applies once you use SDDM."
        if ask "Install and select the login screen?"; then
            want_sddm=1
        else
            done_part sddm "skipped"
        fi
    fi
fi

if (( want_plymouth || want_sddm )); then
    step "System changes"
    note "These need your password."
    if ! sudo -v; then
        fail "Couldn't get administrator rights; skipping the boot animation and login screen."
        (( want_plymouth )) && done_part plymouth "failed (no sudo)"
        (( want_sddm )) && done_part sddm "failed (no sudo)"
        want_plymouth=0 want_sddm=0
    else
        # Keep sudo's timestamp fresh while the initramfs rebuilds.
        (while kill -0 $$ 2>/dev/null; do sudo -n -v 2>/dev/null; sleep 50; done) &
        keepalive=$!
        trap 'kill $keepalive 2>/dev/null' EXIT
    fi
    # Without a display the sub-installers use sudo (cached above) instead of
    # pkexec, so there's one prompt in all.
    run_root() { env -u DISPLAY -u WAYLAND_DISPLAY "$@"; }

    if (( want_plymouth == 2 )); then
        if sudo pacman -S --needed --noconfirm plymouth; then
            want_plymouth=1
        else
            fail "Installing plymouth failed."
            done_part plymouth "failed (pacman)"
            want_plymouth=0
        fi
    fi
    if (( want_plymouth )); then
        if run_root bash "$DIR/scripts/plymouth/install.sh"; then
            done_part plymouth "installed"
        else
            fail "The boot animation couldn't be installed (see above)."
            done_part plymouth "failed"
        fi
    fi
    if (( want_sddm )); then
        if run_root bash "$DIR/sddm/install.sh"; then
            done_part sddm "installed"
        else
            fail "The login screen couldn't be installed (see above)."
            done_part sddm "failed"
        fi
    fi
fi

# --- Start ------------------------------------------------------------------

if [[ $restart -eq 1 && -n "${WAYLAND_DISPLAY:-}" ]] && command -v qs >/dev/null; then
    step "Starting end4-pC"
    pkill -x qs 2>/dev/null || pkill -f '^qs( |$)' 2>/dev/null || true
    (cd "$HOME" && setsid qs -c end4-pC >/dev/null 2>&1 < /dev/null &)
    note "Running. A welcome window opens the first time."
fi

step "Summary"
for p in "${PARTS[@]}"; do
    [[ -n "${result[$p]:-}" ]] && printf '    %-10s %s\n' "$p" "${result[$p]}"
done
echo
