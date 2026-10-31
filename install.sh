#!/usr/bin/env bash
# This fork (bhimio1/end4-pC) is retired. Material 3 Settings now adds the
# same Material 3 integration to pctrade's end4-pC (and to ii, iNiR and Dux
# Shell), so you get pctrade's updates too. This script sets that up,
# asking before each part:
#
#   apps          the essential Material 3 apps (Settings, Files, Screenshots)
#   shell         pctrade's end4-pC in ~/.config/quickshell/end4-pC, with the
#                 Material 3 integration; a checkout of this fork is moved to
#                 end4-pC.fork-backup-<time> first (your settings carry over)
#   default       make end4-pC the shell Hyprland starts (instead of ii)
#   keybinds      add the suggested keybinds that are still free
#   plymouth      the boot animation, in your colors
#   sddm          the end4-material login screen
#
# The last four are also in Settings: Desktop → end4-pC / ii, Shell
# integration and Login & boot.
#
# Usage: install.sh [--yes] [--only PARTS] [--skip PARTS] [--no-restart]
set -uo pipefail

UPSTREAM_URL="https://github.com/pctrade/end4-pC.git"
PARTS=(apps shell default keybinds plymouth sddm)
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/end4-pC"
HYPR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
yes=0 restart=1 only="" skip=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y | --yes) yes=1 ;;
        --only) only="$2"; shift ;;
        --skip) skip="$2"; shift ;;
        --no-restart) restart=0 ;;
        -h | --help) sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
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

# Settings with the shell integration (`m3-settings inject`).
have_settings() { command -v m3-settings >/dev/null && m3-settings inject status >/dev/null 2>&1; }
# Is this folder a checkout of the retired fork?
is_fork() {
    [[ -d "$1/.git" ]] && git -C "$1" remote get-url origin 2>/dev/null | grep -qiE 'bhimio1/end4-pC(\.git)?/?$'
}

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

# --- Material 3 apps --------------------------------------------------------

if wanted apps; then
    step "Material 3 apps (Settings, Files, Screenshots)"
    note "Prebuilt from GitHub releases into ~/.local/bin, or built with cargo when there's no release."
    if ask "Install or update them now?"; then
        if bash "$HERE/scripts/material-apps/install.sh" --update --force --quiet; then
            done_part apps "installed"
        else
            warn "Some apps couldn't be installed (see above)."
            done_part apps "partly installed"
        fi
        hash -r
    else
        done_part apps "skipped"
    fi
fi
if ! have_settings; then
    fail "Material 3 Settings with shell integration (m3-settings inject) isn't installed;"
    fail "the rest needs it. Run this again with the apps part, or install material-3-settings."
    exit 1
fi

# --- Shell ------------------------------------------------------------------

if wanted shell; then
    step "end4-pC (pctrade's, with the Material 3 integration)"
    if is_fork "$DIR"; then
        note "$DIR is this retired fork."
        if ask "Replace it with pctrade's end4-pC? The old folder is kept as a backup."; then
            if m3-settings inject migrate; then
                done_part shell "switched to pctrade's"
            else
                fail "Switching failed (see above); your end4-pC is unchanged."
                done_part shell "failed"
            fi
        else
            done_part shell "kept the fork"
        fi
    else
        if [[ ! -e "$DIR" ]]; then
            mkdir -p "$(dirname "$DIR")"
            git clone -q --depth 1 "$UPSTREAM_URL" "$DIR" || { fail "Cloning $UPSTREAM_URL failed."; exit 1; }
            note "Installed pctrade's end4-pC to $DIR."
        fi
        if m3-settings inject apply end4-pC; then
            done_part shell "integration added"
        else
            fail "Adding the integration failed (see above)."
            done_part shell "failed"
        fi
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

if wanted keybinds; then
    step "Keybinds"
    m3-settings keybinds status | sed 's/^/    /'
    if ask "Add the free ones?"; then
        m3-settings keybinds add && done_part keybinds "added" || done_part keybinds "failed"
    else
        done_part keybinds "skipped"
    fi
fi

# --- Boot animation and login screen ------------------------------------------

if wanted plymouth; then
    step "Boot animation (Plymouth)"
    note "The illogical-impulse emblem, drawn in your current colors. Rebuilds the initramfs."
    if ! command -v plymouth-set-default-theme >/dev/null; then
        note "Plymouth isn't installed (sudo pacman -S plymouth); skipping."
        done_part plymouth "skipped (plymouth not installed)"
    elif ask "Install the boot animation?"; then
        m3-settings login install-plymouth && done_part plymouth "installed" || done_part plymouth "failed"
    else
        done_part plymouth "skipped"
    fi
fi
if wanted sddm; then
    step "Login screen (SDDM)"
    note "end4-material: looks like the lock screen, with your wallpaper and colors."
    if ! command -v sddm >/dev/null; then
        note "SDDM isn't installed; skipping."
        done_part sddm "skipped (SDDM not installed)"
    elif ask "Install and select the login screen?"; then
        m3-settings login install-sddm && done_part sddm "installed" || done_part sddm "failed"
    else
        done_part sddm "skipped"
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
