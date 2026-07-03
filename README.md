# Lain Wired i3 for Omarchy

A square black/red Omarchy rice based on the Torbenn211 dotfiles vibe: default-i3-like bottom bar, hard edges, zero gaps, near-black surfaces, compiler-diagnostic red accents, Lain wallpapers, and terminal-first app configs.

It keeps Lain as the visual center and pushes the surrounding desktop toward a handmade programming-video terminal setup: plain i3 muscle memory first, black/red color second. It does not copy any creator's exact branding, logo, or artwork.

## What It Themes

- Omarchy core: colors, backgrounds, preview, lock colors, Chromium color, icon theme, keyboard RGB.
- Window/session UI: Hyprland, Hyprlock, Waybar, Walker, Wofi, Mako, SwayOSD, Hyprland share picker.
- Terminals: Alacritty, Foot, Ghostty, Kitty.
- Editors and notes: Neovim, Helix, Obsidian, VS Code, VSCodium, Cursor, Zed.
- Browsers: Chromium/Chrome/Brave/Edge through Omarchy policy, plus Firefox/Zen/LibreWolf profile chrome when profiles exist.
- TUI/dev tools: btop, Starship, tmux, LazyGit, Fastfetch, Bat.
- Desktop/app extras: GTK 3/4 surfaces, Typora markdown theme.
- Extras: upstream Omarchy menu restore, bottom i3bar-style Waybar layout, hardware status scripts, developer workspace launcher, Waybar scripts, VS Code-compatible local theme extension.

## TUI Installer

Run this on Omarchy:

```bash
bash install.sh
```

The installer opens a TUI with:

- `Install full rice`
- `Uninstall and restore backups`
- `Show install plan`
- `Show uninstall plan`
- `Show status`

Scripted use:

```bash
bash install.sh --install --yes
bash install.sh --install --yes --reboot
bash install.sh --uninstall --yes
bash install.sh --status
bash install.sh --preview
bash install.sh --install --dry-run
```

The interactive installer asks whether to reboot after a full install. Non-interactive installs do not reboot unless you pass `--reboot`.

## Hosted Repo Install

```bash
omarchy theme install https://github.com/YOUR_USER/omarchy-lain-wired-i3-theme.git
bash ~/.config/omarchy/themes/lain-wired-i3/install.sh
```

`omarchy theme install` applies the core theme. `install.sh` applies the full rice layer that Omarchy does not install by default.

## Backups And Uninstall

The installer creates one-time backups next to files it changes, using:

```text
.before-lain-wired-i3
```

The uninstaller restores those backups when they exist. If a managed file had no previous backup, uninstall removes it.

Managed extra files include:

- `~/.config/waybar/config.jsonc`
- `~/.config/waybar/scripts/*`
- `~/.local/bin/omarchy-lain-dev-layout`
- `~/.config/wofi/style.css`
- `~/.config/starship.toml`
- `~/.config/tmux/tmux.conf`
- `~/.config/lazygit/config.yml`
- `~/.config/fastfetch/lain-logo.txt`
- `~/.config/fastfetch/config.jsonc`
- `~/.config/omarchy/branding/about.txt`
- `~/.config/omarchy/branding/screensaver.txt`
- `~/.config/zed/settings.json`
- `~/.config/gtk-3.0/gtk.css`
- `~/.config/gtk-4.0/gtk.css`
- `~/.config/Typora/themes/lain-wired-i3.css`
- `~/.config/bat/config`
- `~/.config/bat/themes/Lain Wired i3.tmTheme`
- Firefox/Zen/LibreWolf profile `chrome/userChrome.css` and `user.js`

## Optional Settings

```bash
export OMARCHY_I3_WEATHER_LOCATION="Berlin"
export OMARCHY_I3_TODO_FILE="$HOME/todo.txt"
export OMARCHY_I3_DEV_ROOT="$HOME/code/my-project"
export OMARCHY_I3_DEV_URL="https://devdocs.io"
```

Add those to your shell profile or Omarchy environment if you re-enable the optional Waybar weather/todo modules or want the developer launcher to use custom paths.

The developer layout launcher opens a terminal/tmux workspace, editor workspace, browser workspace, and btop workspace. You can also tune workspace numbers with `OMARCHY_I3_DEV_WS_SHELL`, `OMARCHY_I3_DEV_WS_EDITOR`, `OMARCHY_I3_DEV_WS_WEB`, and `OMARCHY_I3_DEV_WS_MONITOR`.

Set `OMARCHY_I3_SKIP_BOOT_THEME=1` before installing if you want to skip the Plymouth/SDDM boot splash step.

## Development Helpers

```bash
scripts/check-theme.sh
scripts/palette.sh
scripts/apply-local.sh --dry-run
scripts/package-theme.sh
```

See [scripts/README.md](scripts/README.md) for details.

## Notes

The Omarchy installer is repo-name based. This package uses `lain-wired-i3` as the local install name, so a GitHub repo named `omarchy-lain-wired-i3-theme` lines up with Omarchy's naming convention.

Check the upstream Torbenn211 dotfiles license before publishing this theme publicly with bundled wallpaper assets.
