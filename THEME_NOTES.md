# Theme Notes

This theme keeps the Lain/i3 center from the original direction and layers a terminal-first systems-programming mood around it. It aims for default-i3 behavior and density first: square windows, zero gaps, no animations, a plain bottom bar, and black/red terminal-video color pressure.

## Omarchy-Native Files

Omarchy applies these through `omarchy-theme-set` and its template system:

- `colors.toml`: source palette for generated Omarchy templates.
- `alacritty.toml`, `foot.ini`, `ghostty.conf`, `kitty.conf`: terminal palettes.
- `waybar.css`, `walker.css`, `mako.ini`, `swayosd.css`: shell UI colors.
- `hyprland.lua`, `hyprlock.conf`: window borders, gaps, lock colors.
- `btop.theme`, `helix.toml`, `obsidian.css`, `vscode.json`: app-specific theme hooks.
- `chromium.theme`, `icons.theme`, `keyboard.rgb`: browser, icon, keyboard accents.
- `backgrounds/`, `preview.png`, `unlock.png`: Omarchy theme previews and wallpapers.

## Installer-Managed Extras

`install.sh` and `extras/omarchy/apply-extras.sh` manage files Omarchy does not apply by itself:

- Default-ish i3bar Waybar config and hardware/status scripts.
- Developer workspace layout command for shell, editor, browser, and monitor workspaces.
- Upstream Omarchy menu restore so stale custom menu overrides do not mask current Omarchy actions.
- Wofi, Starship, tmux, LazyGit, Fastfetch, Omarchy branding, Zed, GTK, Typora, Bat.
- Firefox/Zen/LibreWolf profile `userChrome.css`.
- Local VS Code-compatible theme extension.
- Optional Plymouth/SDDM boot splash application through Omarchy's own boot-theme command.

Every managed target is backed up once with `.before-lain-wired-i3` and restored by uninstall.

## Palette Intent

- `#030403`: near-black terminal background.
- `#090a08`: panel/surface background.
- `#c8c2aa`: warm readable foreground.
- `#343832`: default/inactive i3-style gray.
- `#241815`: focused selection background.
- `#6f9ed0`: retained cool secondary accent.
- `#8fb6dd`: retained bright secondary text accent.
- `#c94f37`: compile error / urgent accent.
- `#d0a85a`: warning / build step.
- `#8ba36f`: success / clean state.
- `#76b7a8`: syscall / IO / string-ish accent.
- `#b58ad6`: macro / metadata accent.

The palette keeps red for focus, identity, and diagnostics, while gray, warm foregrounds, and a little retained blue keep the active window, pane, row, or workspace readable.
