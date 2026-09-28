# Omarchy features to consider for CachyOS

Reviewed on 2026-09-28 using the adjacent `~/dev-projects/omarchy` checkout, branch `quattro`, commit `e332dc975d5f635294c497ebb54feb98dc3d89eb`. This describes that snapshot, rather than assuming older Omarchy guides match it. Source links below are pinned to the reviewed commit.

The current machine runs CachyOS, Hyprland with Lua configuration, Noctalia, Kitty and Fish. The completed dotfiles setup brings over the shell/editor development conveniences. Desktop appearance, window management, Noctalia panels and desktop shortcuts remain available for you to evaluate separately.

## What is configured now

| Area | Available here |
|---|---|
| Shell | Fish's native completion, autosuggestions and highlighting; Starship prompt; Catppuccin shell colors |
| Navigation | `z`, `zi`, `zd`; `..`, `...`, `....` abbreviations |
| Files | eza listing/tree abbreviations; bat previews; ripgrep and fd |
| Fuzzy selection | `ff`, `eff`, `sff`; fzf history/file/directory bindings |
| Development | mise-managed Node 24, Python 3.14 and pnpm 10; uv and pgcli |
| Git | `g`, `gcm`, `gcam`, `gcad`; lazygit; preserved GitHub authentication |
| Sessions | `t` and the repository's existing Omarchy-derived tmux bindings |
| Editor | The repository's LazyVim/Neovim configuration and Catppuccin colors |
| Clipboard | `pbcopy` and `pbpaste` using Wayland tools |
| Updates | `upd` uses paru on this machine; the installer supports `--shell fish` or `--shell zsh` |

These conveniences work without the Omarchy desktop being installed. Fish abbreviations show their expansion before execution; `cd`, `find`, `grep` and `path` retain their native behavior. Docker's UI is installed, but provisioning a Docker engine is a separate task, as in the original dotfiles setup.

Sources: [Omarchy shell tools][shell-tools], [shell functions][shell-functions], [terminal and tmux][terminal].

## Features worth evaluating

| Feature | What you would get | What bringing it here involves |
|---|---|---|
| Unified clipboard shortcuts | The same copy/paste keys in terminals and desktop apps, plus text/image history | Adapt the terminal detection and Hyprland bindings; keep Noctalia's clipboard or choose a replacement |
| Capture workflow | Region/window/full-monitor and scrolling screenshots, annotations, previews and clipboard export | Evaluate Omasnap and its dependencies; map commands into existing bindings |
| Recording workflow | GPU recording with audio choices and optional webcam overlay; stop with the same key | Recorder plus capture scripts, menu integration, output folders and notifications |
| OCR and QR extraction | Select a region and put recognized text or a decoded QR value on the clipboard | Tesseract/QR tooling plus a small capture command; can be independent of the shell |
| Dictation | Hold F9 or use a toggle to type speech into the focused app | Optional Voxtype installation, model selection and a shortcut |
| Sharing and conversion | LocalSend sharing; image/video format and resolution conversion | Individual applications/scripts; Omarchy's integrated picker depends on its menu |
| Window layout toggle | Switch between dwindle tiling and scrolling columns | Adapt the Hyprland layout toggle and select nonconflicting keys |
| Window convenience toggles | Sticky floating windows, transparency, gaps, single-window aspect ratio and full-width mode | Small Hyprland changes are possible independently |
| Tmux developer layouts | Editor, agent and terminal panes; a square layout; one layout per project; tiled command swarms | Port `tdl`, `tds`, `tdlm`, `tsl` from Bash to Fish and choose editor/agent commands |
| Git worktree helpers | Create a sibling worktree/branch and enter it; confirmed cleanup | Port `ga` and `gd`; review naming and branch-deletion behavior before adopting |
| Remote development helpers | SSH port forwarding, rsync watchers and reconnection | Port `fip`/`dip`/`lip`, `rsw`/`lsw`/`dsw` or keep them as standalone scripts |
| Experiment directories | Date-stamped scratch projects through `try` | Install the tool and choose a directory such as `~/dev-projects/tries` |
| Notifications and reminders | Notification history, do-not-disturb, time/battery/weather notices and reminders | Use Noctalia equivalents where available, or port selected commands |
| Integrated panels | Audio mixer, network/DNS, Bluetooth, power profiles, display scaling, calendar and world clock | Much of this belongs to Omarchy's Quickshell desktop; evaluate as a desktop change |
| Coding-agent interface | Agent selection, usage display, lazy launchers and Herdr session management | Optional services and commands; subscriptions/authentication are separate choices |

Sources: [clipboard][clipboard], [capture][capture], [OCR/dictation][dictation], [shell functions][shell-functions], [top bar][bar], [toggles][toggles], [AI integration][ai]. The adoption column is an assessment for this CachyOS machine, not an upstream installation guarantee.

## Keyboard reference

`Super` is the Windows/logo key. These are Omarchy's bindings, **not newly installed bindings on this machine**. The current local bindings were inspected in `~/.config/hypr/config/binds.lua`.

### Desktop and window management

| Omarchy shortcut | Action | Difference from current CachyOS bindings |
|---|---|---|
| `Super+Return` | Terminal | Already launches Kitty here |
| `Super+Alt+Return` | Terminal with tmux | Candidate addition |
| `Super+Space` | Omarchy menu | Currently Noctalia launcher |
| `Super+Alt+Space` | App menu | Currently floating-window toggle |
| `Super+K` | Shortcut reference | Candidate addition |
| `Super+Escape` | System menu | Currently runs `hyprctl kill` |
| `Super+Ctrl+L` | Lock | Current lock is `Super+L` |
| `Super+L` | Dwindle/scrolling layout toggle | Conflicts with current lock |
| `Super+T` | Floating/tiling toggle | Currently launches the editor |
| `Super+O` | Sticky floating window | Candidate addition |
| `Super+F` | Fullscreen | Already fullscreen here |
| `Super+Alt+F` | Full-width window | Candidate addition |
| `Super+Arrows` | Focus neighboring window | Already present |
| `Super+1…9` | Focus workspace | Current `Super+1…3` focuses monitors; workspace keys use additional modifiers |
| `Super+Shift+1…9` | Move window to workspace | Current `Super+Shift+1…3` moves to monitors |
| `Super+Tab` | Next workspace | Currently Noctalia window switcher |
| `Super+S` | Show scratchpad | Already present |
| `Super+Shift+Space` | Toggle top bar | Requires mapping to Noctalia or adopting Omarchy's bar |
| `Super+Backspace` | Window transparency | Candidate addition |
| `Super+Shift+Backspace` | Window gaps | Candidate addition |
| `Super+Ctrl+Alt+F` | Bar/gaps fullscreen desktop mode | Needs coordinated bar/window behavior |

### Clipboard, capture and system controls

| Omarchy shortcut | Action | Current-machine consideration |
|---|---|---|
| `Super+C`, `Super+X`, `Super+V` | Unified copy, cut, paste | Currently calculator, control center and clipboard panel respectively |
| `Super+Ctrl+V` | Clipboard history | Could map to the existing Noctalia panel |
| `Print` | Screenshot | Already Noctalia region capture |
| `Alt+Print` | Start/stop screen recording | Candidate addition |
| `Super+Print` | Color picker | Currently full-screen screenshot; current picker is `Super+P` |
| `Super+Ctrl+Print` | OCR to clipboard | Candidate addition |
| `Super+Ctrl+C` | Capture menu | Requires a menu implementation |
| `Super+Ctrl+.` | Media conversion | Candidate addition |
| `F9`, `Super+Ctrl+X` | Push-to-talk / dictation toggle | Only after installing dictation |
| `Super+Ctrl+A/B/W/D/P` | Audio / Bluetooth / network / display / power panels | Map to Noctalia actions or evaluate Omarchy's panels |
| `Super+,`, `Super+Shift+,` | Dismiss latest/all notifications | Requires notification-service integration |
| `Super+Ctrl+,` | Do-not-disturb toggle | Could map to Noctalia |
| `Super+Ctrl+N` | Night-light toggle | Omarchy uses hyprsunset |
| `Super+Ctrl+I` | Toggle idle locking | Keep this consistent with the active desktop's idle manager |
| `Super+Ctrl+R` | Set reminder | Candidate addition |
| `Super+Ctrl+Shift+Space` | Theme picker | Omarchy's theme system; not a drop-in Noctalia action |
| `Super+Ctrl+Space` | Wallpaper picker | Current wallpaper picker is `Super+Shift+W` |

Sources: [full hotkey reference][hotkeys], [binding implementations][bindings]. Avoid importing the whole binding file: the conflicts above would replace familiar actions.

### Shell and tmux shortcuts available with the dotfiles

| Shortcut | Action |
|---|---|
| `Ctrl+R` | Search shell history with fzf |
| `Ctrl+T` | Insert selected file paths |
| `Alt+C` | Select a directory |
| `Ctrl+Space` or `Ctrl+B` | tmux prefix |
| Prefix then `v` / `h` | Split right / below |
| `Alt+Enter` / `Alt+Shift+Enter` | Split below / right without prefix |
| `Ctrl+Alt+Arrows` | Focus tmux pane |
| `Ctrl+Alt+Shift+Arrows` | Resize tmux pane |
| Prefix then `c`, `r`, `s`, `d` | New window, rename window, list sessions, detach |
| `Alt+1…9` | Select tmux window |
| Prefix then `[` | Copy mode; `v` selects, `y` copies |
| Prefix then `?` | Show tmux keybindings |

## Appearance options

### Coordinated themes

Omarchy's theme switcher coordinates desktop colors, terminal palettes, Neovim, btop, Chromium and its own bar, menus, notifications, on-screen indicators and lock screen. It generates application configuration from a palette and templates, then updates running applications. User templates and theme-specific overrides extend the system. Obsidian needs its theme selected inside the app.

The snapshot contains 22 theme directories. Use the [theme gallery][theme-gallery] to inspect screenshots, and the [complete theme directory][themes] for themes not illustrated in the manual.

| Family to preview | Examples | Reason to evaluate |
|---|---|---|
| Familiar Catppuccin | [Catppuccin][catppuccin], Catppuccin Latte | Extend the palette already used in these dotfiles |
| Cool dark palettes | Tokyo Night, Nord, Kanagawa, Osaka Jade | Alternative blue/green dark environments |
| Warm/muted palettes | Gruvbox, Ristretto, Everforest, Miasma | Lower-key earthy colors |
| Minimal dark | Matte Black, Vantablack | Dark backgrounds and restrained accents |
| Light | Flexoki Light, White, Catppuccin Latte | Daylight-oriented alternatives |
| Distinctive styles | Lumon, Ethereal, Hackerman, Retro 82, Rose Pine, Last Horizon, Lupine, Solitude | Review individual previews rather than adopting the whole theming system |

These groupings are a browsing aid. The screenshots and actual palette files should decide your preference.

### Window shape, spacing and motion

The base configuration uses 5-pixel inner gaps, 10-pixel outer gaps and 2-pixel borders, square corners, and no blur or shadows. Window and layer animations are enabled; workspace animations are disabled. The default layout is dwindle, with scrolling columns available at approximately half a screen wide. Themes can override parts of this baseline.

These settings can be evaluated individually in CachyOS. They do not require replacing Noctalia. Choices to consider: square versus rounded corners, opaque versus translucent terminals, compact versus spacious gaps, subdued versus visible borders, and enabled versus reduced animation.

Sources: [base look and feel][look], [user customization examples][look-custom], [theme implementation][theming].

### Bar, panels and lock screen

This branch uses an integrated **Quickshell-based Omarchy shell**, not a standalone Waybar setup. The bar can move to any edge, toggle transparency and reorder widgets by dragging. Built-in widgets include workspaces, clock/calendar, weather, system tray, agent usage, Bluetooth, networking, audio, display and power; additional widgets include media, microphone and optional service panels. Plugins can add widgets, panels, overlays, services or an entire replacement bar.

The same shell owns notifications, on-screen indicators, clipboard history, idle behavior and locking. Adopting it alongside Noctalia would require deciding which shell owns each function. For a gradual setup, borrowing colors, spacing and a few commands is a smaller change than replacing the shell.

Sources: [bar and panel guide][bar], [plugin system][plugins], [idle behavior][toggles].

### Terminals and fonts

Foot is the default terminal in this snapshot; Kitty, Alacritty and Ghostty are supported alternatives. Foot does not provide native tabs/splits, so Omarchy promotes tmux for persistent sessions. Your existing Kitty already supplies a suitable terminal. Matching its font and palette to the dotfiles is an optional future appearance change.

Boot/decryption artwork is a separate theme feature. It is unrelated to configuring Fish and should be evaluated independently of the running desktop.

Source: [terminal guide][terminal], [themes and unlock previews][theme-gallery].

## Suggested order for trying changes

1. Use the configured Fish, fzf, zoxide, tmux and LazyVim setup first.
2. Consider a few independent additions: OCR capture, a screenshot annotation tool, tmux developer layouts or `try`.
3. Choose individual shortcut changes after reviewing the conflict tables.
4. Pick a terminal/window palette and spacing style from the preview galleries.
5. Evaluate the Omarchy shell only if its integrated bar, panels and lock screen are preferable to Noctalia.

Keep CachyOS's package repositories, kernels, bootloader and snapshot setup as a separate system decision. Omarchy's update command coordinates its own packages, snapshots and migrations; its documented bootable snapshot workflow relies on Limine and does not restore `/home`. Those scripts are not appropriate to run just because this reference checkout is present. Sources: [updates][updates], [snapshots][snapshots].

[shell-tools]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/19-shell-tools.md
[shell-functions]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/20-shell-functions.md
[terminal]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/15-terminal.md
[clipboard]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/08-unified-clipboard-history.md
[capture]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/12-screenshots-recording.md
[dictation]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/11-text-extraction-dictation.md
[bar]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/05-the-top-bar.md
[toggles]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/13-toggles-idle-screensaver.md
[ai]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/17-ai.md
[hotkeys]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/07-hotkeys.md
[bindings]: https://github.com/omacom/omarchy/tree/e332dc975d5f635294c497ebb54feb98dc3d89eb/default/hypr/bindings
[theme-gallery]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/06-themes.md
[themes]: https://github.com/omacom/omarchy/tree/e332dc975d5f635294c497ebb54feb98dc3d89eb/themes
[catppuccin]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/themes/catppuccin/preview.png
[look]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/default/hypr/looknfeel.lua
[look-custom]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/config/hypr/looknfeel.lua
[theming]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/docs/theming.md
[plugins]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/32-shell-plugins.md
[updates]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/30-updates.md
[snapshots]: https://github.com/omacom/omarchy/blob/e332dc975d5f635294c497ebb54feb98dc3d89eb/manual/47-system-snapshots.md
