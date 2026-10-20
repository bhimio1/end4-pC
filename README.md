



<div align="center">

# 💠 end4-pC

**A personal fork of [illogical-impulse](https://github.com/end-4/dots-hyprland) by [@end-4](https://github.com/end-4)**  
Customized and maintained by **pctrade**

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
cd ~/.config/quickshell/
git clone https://github.com/bhimio1/end4-pC.git
killall qs 2>/dev/null; qs -c end4-pC > /dev/null 2>&1 & disown
```

### 🔧 Set as your default shell (optional)

If you like it and want it to load by default instead of `ii`, edit:

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

This fork uses four companion apps that follow the shell's Material You colors:

- [**Material 3 Settings**](https://github.com/bhimio1/material-3-settings) (`m3-settings`) for system settings: Wi-Fi, Bluetooth, sound, displays, packages, Hyprland, app configs, and all of the shell's own options.
- [**Material 3 File Manager**](https://github.com/bhimio1/material-3-file-manager-rust) (`m3fm`) for folders.
- [**Material 3 Games**](https://github.com/bhimio1/material-3-games) (`m3-games`), a game library for Steam, Lutris, Heroic and other games, with a Game Mode (see below).
- [**Material 3 Browser**](https://github.com/bhimio1/material-3-browser) (`m3-browser`), Zen (or LibreWolf/Firefox) with a Material 3 look that themes websites with your colors.

**They install themselves.** About 15 seconds after the shell starts, `scripts/material-apps/install.sh` installs whichever app is missing into `~/.local/bin`, with a desktop entry in `~/.local/share/applications`.

- **Where the apps come from:** the latest GitHub release when there is one, otherwise a build from source with `cargo`.
- **Updates:** checked once a day, only for copies the script installed. Apps installed through pacman or the AUR are left alone.
- **Manual run:** the **Material 3 apps** button in the shell settings' About page does an install or update now.
- **Turning it off:** set `apps.autoInstallMaterialApps` to `false`.
- **Update Dots** pulls this fork, not upstream, and updates the apps as well.

Where the apps are used:

- **Wi-Fi and Bluetooth "more settings"** buttons in the right sidebar open the matching m3-settings page.
- **Right sidebar** has a **System settings** button (tune icon) next to the shell settings button.
- **Desktop right-click menu** has **System settings** and **Files** entries.
- **Folder buttons** open in m3fm: the avatar folder, the recordings folder, color schemes and preset uploads.
- **Dock and launcher** pin the file manager by default, and the dock also pins the browser.
- **Colors:** both apps read the shell's generated `colors.json` directly, so they recolor live whenever the wallpaper or color scheme changes.

**Fallbacks:** without m3-settings, the Wi-Fi and Bluetooth buttons use KDE's modules and System settings opens the shell settings. Without m3fm, folders open with `xdg-open`.

**Config:** the commands live in `~/.config/illogical-impulse/config.json` under `apps` (`settings`, `fileManager`, `network`, `networkEthernet`, `bluetooth`). Configs that still had older defaults are switched over automatically; values you changed are left alone.

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

---

<div align="center">

Made with ❤️ — feel free to fork and make it your own

</div>
