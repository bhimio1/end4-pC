



<div align="center">

# 💠 end4-pC

**A personal fork of [illogical-impulse](https://github.com/end-4/dots-hyprland) by [@end-4](https://github.com/end-4)**  
Customized and maintained by **pctrade**

This copy, [bhimio1/end4-pC](https://github.com/bhimio1/end4-pC), builds on pctrade's fork. It adds a family of [Material 3 apps](#-material-3-apps) that follow the shell's colors, Game Mode, a boot animation and CachyOS support.

[English](README.md) | [简体中文](README.zh-CN.md) | [日本語](README.ja.md)

</div>

---

## 🎬 Showcase

<p align="center">
  <a href="https://www.youtube.com/watch?v=o0Vsh7eVchs">
    <img src="https://img.youtube.com/vi/o0Vsh7eVchs/maxresdefault.jpg" alt="Material 3 Expressive x Linux" width="85%" style="border-radius: 12px; box-shadow: 0px 10px 30px rgba(0,0,0,0.5);"/>
  </a>
</p>

</div>

---

## 📸 Screenshots
<div align="center">

| 🎵 Lyrics | 🖼️ Online Wallpapers |
|:---:|:---:|
| ![Screenshot 1](screenshots/1.png) | ![Screenshot 2](screenshots/2.png) |
| 🪟 Desktop Widgets | 🔧 Hyprland Configs |
| ![Screenshot 5](screenshots/5.png) | ![Screenshot 6](screenshots/6.png) |
| ⚙️ Configurable Bar | ✨ And More |
| ![Screenshot 3](screenshots/3.png) | ![Screenshot 4](screenshots/4.png) |

</div>

---

## 🎨 Community Presets

Share your whole desktop with one button, or try someone else's in a click.

**[end4-pCpresets](https://github.com/pctrade/end4-pCpresets)** is the community gallery for this shell. Open **Dashboard → Presets**, pick a preset and press **Download** to try it or **Install** to keep it. Made your own? Press **Upload**, choose a screenshot and it is sent for you with one click. The first time, a terminal opens to install the [GitHub CLI](https://cli.github.com) (`gh`) and sign you in, which takes a minute. If you skip that, the shell opens a GitHub page where you drag the folder in instead. Changed your mind? **Remove from gallery** takes your own preset back out.

- 🔒 **Private by design:** nothing is collected from you. The shell only reads public files from GitHub.
- 🧹 **Clean exports:** personal paths, keys and commands are removed before anything is shared.
- ✅ **Every preset is checked** automatically. First-time authors are reviewed by hand, and trusted authors are merged automatically once the check passes.
- 👤 **Yours stays yours:** only the person who shared a preset can change or remove it.

[Browse the gallery](https://github.com/pctrade/end4-pCpresets) · [How to share yours](https://github.com/pctrade/end4-pCpresets#share-your-preset)

---

## ⚡ Installation

> [!NOTE]
> This fork manages its own configuration folder independently — it does **not** overwrite or modify any existing setup. However, it does require [illogical-impulse](https://github.com/end-4/dots-hyprland) to be installed and running.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/bhimio1/end4-pC/main/install.sh)
```

The installer asks before each part, and every part is safe to run again:

| Part | What it does |
|---|---|
| `shell` | Clones end4-pC into `~/.config/quickshell/end4-pC`, or updates it. |
| `apps` | Installs the essential [Material 3 apps](#-material-3-apps) (Settings, Files, Screenshots). |
| `default` | Makes Hyprland start end4-pC instead of `ii` (backup of `variables.lua` kept). |
| `keybinds` | Adds the suggested keybinds to `~/.config/hypr/custom/keybinds.lua`, only for keys your config doesn't use yet. |
| `plymouth` | The [boot animation](#-boot-animation-optional) in your colors (installs `plymouth` if needed). |
| `sddm` | The [login screen](#-login-screen-optional), when SDDM is installed. |

After the first start, a welcome opens: Settings' (`m3-settings --welcome`) with your wallpaper, colors, optional apps, default apps and keybinds, or the shell's own welcome when Settings isn't installed. Open it again any time from Settings → About.

The system parts ask for your password once. `--yes` installs everything without asking; `--only plymouth,sddm` or `--skip keybinds` pick parts. From a clone, run `~/.config/quickshell/end4-pC/install.sh`. Run it again after changing wallpaper to redraw the boot animation in the new colors.

**By hand**, without the installer:

```bash
cd ~/.config/quickshell/
git clone https://github.com/bhimio1/end4-pC.git
killall qs 2>/dev/null; qs -c end4-pC > /dev/null 2>&1 & disown
```

Works on Arch and CachyOS. System updates use paru, then yay, then plain pacman, whichever is installed.

### 🔧 Set as your default shell (optional)

The installer's `default` part does this. By hand, to load it by default instead of `ii`, edit:

```bash
~/.config/hypr/hyprland/variables.lua
```

And change this line:

```lua
hl.env("qsConfig", "ii")
```

to:

```lua
hl.env("qsConfig", "end4-pC")
```

> [!TIP]
> After saving, restart Hyprland or run `hyprctl reload` to apply the change.

---

### ⚙️ Settings keybind

To open the settings panel, add this to your Hyprland config:

```lua
hl.bind("SUPER + escape", hl.dsp.global("quickshell:settingsToggle"), {description = "Toggle settings"})
```

> **Note:** Settings is an overlay panel, not a regular window — `Super + Q` won't close it. Use the same keybind to toggle it or press `Escape`.

---

### 🧩 Material 3 apps

Companion apps written in Rust with the same Material 3 look. They read the shell's generated `colors.json`, so they recolor live whenever your wallpaper or color scheme changes.

**Essential apps** come with the shell, which relies on them:

| App | Command | What it's for |
|---|---|---|
| [**Settings**](https://github.com/bhimio1/material-3-settings) | `m3-settings` | Wi-Fi, Bluetooth, sound, displays, power, packages (Arch/CachyOS), Hyprland, config files for 50+ apps, every shell option, and the other Material 3 apps |
| [**Files**](https://github.com/bhimio1/material-3-file-manager-rust) | `m3fm` | File manager with tabs, previews, Google Drive and the system file picker |
| [**Screenshots**](https://github.com/bhimio1/material-3-screenshots) | `m3-screenshots` | Region, window and screen captures, an annotation editor, screen recording and a capture history |

**Optional apps** are installed when you want them, from **Settings → Material 3 apps**:

| App | Command | What it's for |
|---|---|---|
| [**Music**](https://github.com/bhimio1/material-3-music) | `m3-music` | YouTube Music with Google sign-in and library sync, local files and downloads |
| [**Games**](https://github.com/bhimio1/material-3-games) | `m3-games` | Steam, Lutris, Heroic and other games, Steam Input, guides, achievements, and [Game Mode](#-games-and-game-mode) |
| [**Browser**](https://github.com/bhimio1/material-3-browser) | `m3-browser` | Zen (or LibreWolf/Firefox) with a Material 3 look that themes websites in your colors, plus uBlock Origin |
| [**AI**](https://github.com/bhimio1/material-3-ai) | `m3-ai` | A desktop app for Claude Code: chats per project, tool cards, diffs and permission prompts |
| [**Viewer**](https://github.com/bhimio1/material-3-veiwer) | `m3-viewer` | Photos and videos in one window: animated images, SVG, RAW previews, EXIF, slideshows, crop/rotate/adjust, and video with subtitles and audio tracks |
| [**Text**](https://github.com/bhimio1/material-3-text) | `m3-text` | A text and code editor: tabs, a file tree, multiple cursors, folder search, Markdown preview, and fast on huge files |
| [**Monitor**](https://github.com/bhimio1/material-3-monitor) | `m3-monitor` | Live CPU, memory, GPU, disk and network charts, plus processes, services and startup apps |
| [**Calendar**](https://github.com/bhimio1/material-3-calendar) | `m3-calendar` | Google, Microsoft, iCloud, CalDAV and local calendars with browser sign-in, offline cache and reminders |

#### Installing and updating

About 15 seconds after the shell starts, `scripts/material-apps/install.sh` installs any missing essential app into `~/.local/bin`, with a desktop entry in `~/.local/share/applications`.

- **Where they come from:** the latest GitHub release when there is one, otherwise a build from source (`cargo`). An app whose repository has nothing published yet is skipped quietly.
- **Updates:** checked once a day, only for copies the script installed. Copies from pacman or the AUR (`material-3-*-bin` / `-git`) are left alone.
- **Manual run:** the **Material 3 apps** button in the shell settings' About page installs or updates the essential apps now.
- **Turning it off:** set `apps.autoInstallMaterialApps` to `false` in the config.
- **Update Dots** pulls this fork, not upstream, and then updates the essential apps.

**Settings → Material 3 apps** (`m3-settings material-apps`) manages all of them. It installs optional apps from the AUR when you have paru or yay, otherwise from the GitHub release, and updates, opens and removes them. It lists the essential apps too, so you can update them, but it doesn't remove them. Apps an older version of the shell installed are picked up as they are, without being reinstalled.

Each app offers to install what it needs. For example, Music needs `mpv` and `yt-dlp`, Browser needs Zen (`zen-browser-bin`), LibreWolf or Firefox, and AI needs [Claude Code](https://docs.claude.com/en/docs/claude-code) signed in with your own account.

#### Where the shell uses them

- **Right sidebar:**
  - the Wi-Fi and Bluetooth "more settings" buttons open the matching Settings page;
  - a **System settings** button (tune icon) sits next to the shell settings button;
  - right-click the **Game mode** toggle to open the game library.
- **Desktop right-click menu:** System settings, Files, Games, Music, AI, Browser, and **More Material 3 apps**, which opens the Settings page.
- **Screenshots:** the shell's region selector (screen snip, `Super+Shift+S` in end-4's keybinds) stays as it is, with freeze, OCR and image search. When it copies a region, the capture goes to Screenshots, which copies and saves it by its own settings, shows a notification with Edit, and keeps it in its history. Right-click selection opens the capture in Screenshots' editor instead of swappy or satty. Set `apps.screenshots` to `""` to keep the shell's built-in handling.
- **Calendar:** with Calendar installed, the sidebar's month calendar shows a dot in each calendar's color on days with events, a click on a day opens that day in Calendar, and an open button sits next to the month arrows. The events come from Calendar's offline cache and update live when its background service syncs.
- **Folder buttons** open in Files: the avatar folder, the recordings folder, color schemes and preset uploads.
- **Games overlay:** a library with recently played games and one-click launch (see below).
- **Media widgets:** Music shows up as a normal media player (MPRIS), so the shell's media controls and your media keys work with it.
- **Dock:** Files and Browser are pinned by default, and the launcher pins Files and Settings.

**Fallbacks:** without Settings, the Wi-Fi and Bluetooth buttons open KDE's modules and System settings opens the shell settings. Without Files, folders open with `xdg-open`. An optional app that isn't installed yet opens its page in Settings, with an Install button.

**Config:** the commands live in `~/.config/illogical-impulse/config.json` under `apps` (`settings`, `fileManager`, `screenshots`, `network`, `networkEthernet`, `bluetooth`, `autoInstallMaterialApps`). Configs that still had older defaults are switched over automatically; values you changed are left alone.

**Keybinds:** add any of these to `~/.config/hypr/custom/keybinds.lua`:

```lua
hl.bind("SUPER + I", hl.dsp.exec_cmd("m3-settings"), {description = "System settings"})
hl.bind("SUPER + E", hl.dsp.exec_cmd("m3fm"), {description = "Files"})
hl.bind("SUPER + M", hl.dsp.exec_cmd("m3-music"), {description = "Music"})
hl.bind("SUPER + A", hl.dsp.exec_cmd("m3-ai"), {description = "AI"})
hl.bind("SUPER + W", hl.dsp.exec_cmd("m3-browser"), {description = "Browser"})
hl.bind("Print", hl.dsp.exec_cmd("m3-screenshots output --active"), {description = "Screenshot of this screen"})
hl.bind("SUPER + Print", hl.dsp.exec_cmd("m3-screenshots window --active"), {description = "Screenshot of this window"})
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("m3-screenshots record region --toggle"), {description = "Record a region (again to stop)"})
```

These keys may already be taken in your setup; pick free ones.

### 🎮 Games and Game Mode

**Opening the library.** Press the bound key, choose **Games** in the desktop right-click menu, or right-click the **Game mode** quick toggle. The overlay shows recently played games and your whole library (from Material 3 Games), with search and keyboard navigation. Click a game to launch it.

**Launching from the desktop.** Games launched here still run under Hyprland. Material 3 Games installs window rules for games (tearing allowed, idle inhibit, no animations, blur or shadows) and forces the game's window fullscreen as soon as it opens. It also switches off Hyprland's animations and blur until you quit the game.

**Game Mode** goes further, to get back the frames Hyprland costs:

1. It closes your open apps and exits Hyprland.
2. It starts **gamescope**, a small compositor made for games, with a full-screen, controller-friendly library like Steam's Big Picture.
3. Choosing *Exit to desktop* brings Hyprland back.

This needs the **Hyprland (with Game Mode)** session, which Material 3 Games installs. Pick it once at your login screen. In a normal Hyprland session, Game Mode runs gamescope full-screen inside Hyprland instead.

Bind the library and Game Mode in `~/.config/hypr/custom/keybinds.lua`:

```lua
hl.bind("SUPER + G", hl.dsp.global("quickshell:gamesToggle"), {description = "Game library"})
hl.bind("SUPER + SHIFT + G", hl.dsp.global("quickshell:gameMode"), {description = "Game Mode"})
```

To open m3-settings from a key, add this to `~/.config/hypr/custom/keybinds.lua`:

```lua
hl.bind("SUPER + I", hl.dsp.exec_cmd("m3-settings"), {description = "System settings"})
```

---

### 🚀 Boot animation (optional)

A Plymouth boot splash made from the illogical-impulse emblem. The disc fades in, the ring sweeps to its arrowhead, the asterisk spins into place and the dots pop in. While the system boots, the ring and dots keep turning around the asterisk. Encrypted disks get a matching password box.

The main installer sets this up (`install.sh --only plymouth`). On its own:

```bash
~/.config/quickshell/end4-pC/scripts/plymouth/install.sh
```

The frames are drawn in your current end4-pC colors, so the boot screen matches your desktop. Run the installer again after changing wallpaper; `--default-colors` uses the logo's teal instead. It asks for your password once, installs the theme and rebuilds the initramfs. If Plymouth isn't set up yet, it tells you what to add:

- the `plymouth` hook in `/etc/mkinitcpio.conf`;
- `quiet splash` on the kernel command line.

CachyOS usually has both already. Rendering needs `rsvg-convert` (librsvg), `python-cairosvg` or ImageMagick.

The emblem is end-4's illogical-impulse logo, from [dots-hyprland](https://github.com/end-4/dots-hyprland) (GPL-3.0).

---

### 🔑 Login screen (optional)

An SDDM theme, **end4-material**, that looks like the shell's lock screen: your wallpaper blurred behind, the clock, your avatar, the password box in a Material 3 toolbar, and islands for the session (Hyprland, Hyprland with Game Mode, …), keyboard layout and power. It warns when Caps Lock is on, shakes on a wrong password, lists every user, and works on HiDPI and on every monitor.

<p align="center"><img src="sddm/theme/preview.jpg" alt="end4-material login screen" width="85%"/></p>

The main installer sets this up (`install.sh --only sddm`). On its own:

```bash
~/.config/quickshell/end4-pC/sddm/install.sh
```

It asks for your password once, installs the theme to `/usr/share/sddm/themes/end4-material` and selects it with `/etc/sddm.conf.d/zz-end4-material.conf`. If `/etc/sddm.conf` already picks a theme, that line is commented out (backup: `/etc/sddm.conf.end4-material.bak`). Needs SDDM 0.21 or newer (Qt 6); ImageMagick is recommended.

**What syncs:** the greeter runs as the `sddm` user and can't read your home, so `sddm/sync.sh` copies what it needs to `/var/lib/end4-material-sddm` (owned by you, readable by everyone, writable only by you): the wallpaper (or the lock-screen wallpaper and its colors, if you set one; a video's thumbnail), a pre-blurred copy, the Material You colors from `colors.json`, your font and clock settings, fonts that only exist in `~/.local/share/fonts`, and your avatar. The wallpaper switcher runs it after every change, so the login screen follows your desktop. Missing or broken files just mean the default look.

**Picking it by hand:** set `Current=end4-material` under `[Theme]` in a file in `/etc/sddm.conf.d/`, or choose it in your desktop's SDDM settings. `install.sh --no-select` installs without selecting.

**Uninstall:** `sddm/install.sh --uninstall` removes the theme and the sync folder and restores the previous theme.

---

## ❓ FAQ

### How do I see my keybinds?

Open the launcher (`SUPER`) and type `<` — it'll show you the full list of configured keybinds.

### Why doesn't Settings have a search bar?

It doesn't need one — the launcher already does that job. Open the launcher (`SUPER`) and just type what you're looking for (e.g. `wallpaper`, `bar`, `blur`); it'll match against page names and section keywords and jump you straight to the right Settings page, so there's no need for a separate search inside Settings itself.

---

## 🙏 Credits

Huge thanks to the people who made this possible:

- **[@end-4](https://github.com/end-4)** — for creating the original [dots-hyprland](https://github.com/end-4/dots-hyprland) / illogical-impulse shell. An absolute masterpiece of a dotfiles project 🫡
- **[@gh0stzk](https://github.com/gh0stzk)** — for providing the weather API integration that made the weather widget possible 🙌
- **[@StarS2112](https://github.com/StarS2112)** — for showcasing this fork 🙌
- **[@simeulinuxkaliaiwr](https://github.com/simeulinuxkaliaiwr)** — for some shader transitions 🎨
- **[pctrade](https://github.com/pctrade/end4-pC)** — for end4-pC, which this copy builds on

---

<div align="center">

Made with ❤️ — feel free to fork and make it your own

</div>
