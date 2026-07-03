# Theme Notes

This theme keeps the Lain/i3 center from the original direction and layers a terminal-first systems-programming mood around it. It is inspired by handmade programming-stream/devlog desktops, but it does not copy any person's branding, logo, or art.

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

- Full i3-style developer Waybar config and project/status scripts.
- Developer workspace layout command for shell, editor, browser, and monitor workspaces.
- Custom Omarchy menu override.
- Wofi, Starship, tmux, LazyGit, Fastfetch, Zed, GTK, Typora, Bat.
- Firefox/Zen/LibreWolf profile `userChrome.css`.
- Local VS Code-compatible theme extension.

Every managed target is backed up once with `.before-lain-wired-i3` and restored by uninstall.

## Palette Intent

- `#030403`: near-black terminal background.
- `#090a08`: panel/surface background.
- `#c8c2aa`: warm readable foreground.
- `#343832`: default/inactive i3-style gray.
- `#0d1722`: focused selection background.
- `#6f9ed0`: mild ImGui/i3 focus blue.
- `#8fb6dd`: focused text / bright blue.
- `#c94f37`: compile error / urgent accent.
- `#d0a85a`: warning / build step.
- `#8ba36f`: success / clean state.
- `#76b7a8`: syscall / IO / string-ish accent.
- `#b58ad6`: macro / metadata accent.

The palette keeps Lain red for identity and diagnostics, while focus states use gray-to-blue so the active window, pane, row, or workspace reads clearly.
