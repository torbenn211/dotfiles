#!/usr/bin/env bash
set -euo pipefail

theme_dir="${OMARCHY_THEME_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)}"
stamp="lain-wired-i3"
ext_dir_name="omarchy-lain-wired.lain-wired-i3-0.1.0"

action="${1:-install}"
if [[ "$action" != "install" && "$action" != "uninstall" && "$action" != "status" ]]; then
  action="install"
fi

theme_name="${2:-$(basename "$theme_dir")}"

log() {
  printf '[%s] %s\n' "$stamp" "$*"
}

backup_once() {
  local target="$1"
  [[ -e "$target" ]] || return 0
  local backup="${target}.before-${stamp}"
  if [[ ! -e "$backup" ]]; then
    log "Backing up $target -> $backup"
    cp -a "$target" "$backup"
  fi
}

copy_file() {
  local src="$1"
  local dst="$2"
  backup_once "$dst"
  log "Installing $dst"
  install -Dm644 "$src" "$dst"
}

copy_exec() {
  local src="$1"
  local dst="$2"
  backup_once "$dst"
  log "Installing executable $dst"
  install -Dm755 "$src" "$dst"
}

restore_or_remove() {
  local target="$1"
  local backup="${target}.before-${stamp}"

  if [[ -e "$backup" ]]; then
    log "Restoring backup $backup -> $target"
    rm -f "$target"
    mv "$backup" "$target"
  elif [[ -e "$target" ]]; then
    log "Removing managed file $target"
    rm -f "$target"
  fi
}

install_waybar() {
  [[ -f "$theme_dir/extras/waybar/config.jsonc" ]] || return 0
  copy_file "$theme_dir/extras/waybar/config.jsonc" "$HOME/.config/waybar/config.jsonc"

  local script
  for script in "$theme_dir"/extras/waybar/scripts/*; do
    [[ -f "$script" ]] || continue
    copy_exec "$script" "$HOME/.config/waybar/scripts/$(basename "$script")"
  done
}

uninstall_waybar() {
  restore_or_remove "$HOME/.config/waybar/config.jsonc"

  local script
  for script in cputemp.sh gitstatus.sh gputemp.sh gpuusage.sh keystroke.py project.sh todo.sh traffic.sh updates.sh weather.sh; do
    restore_or_remove "$HOME/.config/waybar/scripts/$script"
  done
}

install_menu() {
  [[ -f "$theme_dir/extras/omarchy/menu.sh" ]] || return 0
  copy_exec "$theme_dir/extras/omarchy/menu.sh" "$HOME/.config/omarchy/extensions/menu.sh"
}

uninstall_menu() {
  restore_or_remove "$HOME/.config/omarchy/extensions/menu.sh"
}

install_dev_layout() {
  [[ -f "$theme_dir/extras/omarchy/dev-layout.sh" ]] || return 0
  copy_exec "$theme_dir/extras/omarchy/dev-layout.sh" "$HOME/.local/bin/omarchy-lain-dev-layout"
}

uninstall_dev_layout() {
  restore_or_remove "$HOME/.local/bin/omarchy-lain-dev-layout"
}

install_wofi() {
  [[ -f "$theme_dir/wofi.css" ]] || return 0
  copy_file "$theme_dir/wofi.css" "$HOME/.config/wofi/style.css"
}

uninstall_wofi() {
  restore_or_remove "$HOME/.config/wofi/style.css"
}

install_app_configs() {
  [[ -f "$theme_dir/extras/apps/starship.toml" ]] && copy_file "$theme_dir/extras/apps/starship.toml" "$HOME/.config/starship.toml"
  [[ -f "$theme_dir/extras/apps/tmux.conf" ]] && copy_file "$theme_dir/extras/apps/tmux.conf" "$HOME/.config/tmux/tmux.conf"
  [[ -f "$theme_dir/extras/apps/lazygit.yml" ]] && copy_file "$theme_dir/extras/apps/lazygit.yml" "$HOME/.config/lazygit/config.yml"
  [[ -f "$theme_dir/extras/apps/fastfetch.jsonc" ]] && copy_file "$theme_dir/extras/apps/fastfetch.jsonc" "$HOME/.config/fastfetch/config.jsonc"
  [[ -f "$theme_dir/extras/apps/zed-settings.json" ]] && copy_file "$theme_dir/extras/apps/zed-settings.json" "$HOME/.config/zed/settings.json"
  [[ -f "$theme_dir/extras/apps/gtk.css" ]] && copy_file "$theme_dir/extras/apps/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
  [[ -f "$theme_dir/extras/apps/gtk.css" ]] && copy_file "$theme_dir/extras/apps/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
  [[ -f "$theme_dir/extras/apps/typora-lain-wired-i3.css" ]] && copy_file "$theme_dir/extras/apps/typora-lain-wired-i3.css" "$HOME/.config/Typora/themes/lain-wired-i3.css"
  install_bat_theme
}

uninstall_app_configs() {
  restore_or_remove "$HOME/.config/starship.toml"
  restore_or_remove "$HOME/.config/tmux/tmux.conf"
  restore_or_remove "$HOME/.config/lazygit/config.yml"
  restore_or_remove "$HOME/.config/fastfetch/config.jsonc"
  restore_or_remove "$HOME/.config/zed/settings.json"
  restore_or_remove "$HOME/.config/gtk-3.0/gtk.css"
  restore_or_remove "$HOME/.config/gtk-4.0/gtk.css"
  restore_or_remove "$HOME/.config/Typora/themes/lain-wired-i3.css"
  uninstall_bat_theme
}

install_bat_theme() {
  [[ -f "$theme_dir/extras/apps/bat/config" ]] || return 0
  [[ -f "$theme_dir/extras/apps/bat/Lain Wired i3.tmTheme" ]] || return 0

  copy_file "$theme_dir/extras/apps/bat/config" "$HOME/.config/bat/config"
  copy_file "$theme_dir/extras/apps/bat/Lain Wired i3.tmTheme" "$HOME/.config/bat/themes/Lain Wired i3.tmTheme"

  if command -v bat >/dev/null 2>&1; then
    log "Rebuilding bat theme cache"
    bat cache --build >/dev/null 2>&1 || true
  fi
}

uninstall_bat_theme() {
  restore_or_remove "$HOME/.config/bat/config"
  restore_or_remove "$HOME/.config/bat/themes/Lain Wired i3.tmTheme"

  if command -v bat >/dev/null 2>&1; then
    log "Rebuilding bat theme cache"
    bat cache --build >/dev/null 2>&1 || true
  fi
}

browser_profiles() {
  shopt -s nullglob
  local profile
  for profile in "$HOME"/.mozilla/firefox/* "$HOME"/.librewolf/* "$HOME"/.zen/*; do
    [[ -d "$profile" ]] || continue
    [[ -f "$profile/prefs.js" || -f "$profile/user.js" ]] || continue
    printf '%s\n' "$profile"
  done
}

install_firefox_like_profiles() {
  [[ -f "$theme_dir/extras/apps/firefox-userChrome.css" ]] || return 0

  local profile user_js
  while IFS= read -r profile; do
    [[ -n "$profile" ]] || continue
    copy_file "$theme_dir/extras/apps/firefox-userChrome.css" "$profile/chrome/userChrome.css"

    user_js="$profile/user.js"
    backup_once "$user_js"
    mkdir -p "$(dirname "$user_js")"
    touch "$user_js"
    if ! grep -q 'toolkit.legacyUserProfileCustomizations.stylesheets' "$user_js"; then
      log "Enabling userChrome.css in $user_js"
      printf '\n// Lain Wired i3\nuser_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);\n' >> "$user_js"
    fi
  done < <(browser_profiles)
}

uninstall_firefox_like_profiles() {
  local profile
  while IFS= read -r profile; do
    [[ -n "$profile" ]] || continue
    restore_or_remove "$profile/chrome/userChrome.css"
    restore_or_remove "$profile/user.js"
  done < <(browser_profiles)
}

install_vscode_extension() {
  local src="$theme_dir/extras/vscode-extension"
  [[ -f "$src/package.json" ]] || return 0

  local extension_dirs=(
    "$HOME/.vscode/extensions"
    "$HOME/.vscode-insiders/extensions"
    "$HOME/.vscode-oss/extensions"
    "$HOME/.vscodium/extensions"
    "$HOME/.cursor/extensions"
  )

  local dir
  for dir in "${extension_dirs[@]}"; do
    mkdir -p "$dir"
    log "Installing VS Code-compatible theme extension $dir/$ext_dir_name"
    rm -rf "$dir/$ext_dir_name"
    cp -R "$src" "$dir/$ext_dir_name"
  done
}

uninstall_vscode_extension() {
  local extension_dirs=(
    "$HOME/.vscode/extensions"
    "$HOME/.vscode-insiders/extensions"
    "$HOME/.vscode-oss/extensions"
    "$HOME/.vscodium/extensions"
    "$HOME/.cursor/extensions"
  )

  local dir
  for dir in "${extension_dirs[@]}"; do
    if [[ -d "$dir/$ext_dir_name" ]]; then
      log "Removing VS Code-compatible theme extension $dir/$ext_dir_name"
      rm -rf "$dir/$ext_dir_name"
    fi
  done
}

restart_apps() {
  command -v omarchy-theme-set-vscode >/dev/null 2>&1 && omarchy-theme-set-vscode || true
  command -v omarchy-restart-waybar >/dev/null 2>&1 && omarchy-restart-waybar || true
  command -v omarchy-restart-walker >/dev/null 2>&1 && omarchy-restart-walker || true
  command -v omarchy-restart-tmux >/dev/null 2>&1 && omarchy-restart-tmux || true
  command -v omarchy-restart-btop >/dev/null 2>&1 && omarchy-restart-btop || true
  command -v makoctl >/dev/null 2>&1 && makoctl reload || true
}

status_line() {
  local label="$1"
  local path="$2"
  if [[ -e "$path" ]]; then
    printf 'yes  %s (%s)\n' "$label" "$path"
  else
    printf 'no   %s (%s)\n' "$label" "$path"
  fi
}

show_status() {
  status_line "theme directory" "$theme_dir"
  status_line "theme-set hook" "$HOME/.config/omarchy/hooks/theme-set.d/90-lain-wired-i3-extras"
  status_line "waybar config" "$HOME/.config/waybar/config.jsonc"
  status_line "menu override" "$HOME/.config/omarchy/extensions/menu.sh"
  status_line "developer layout command" "$HOME/.local/bin/omarchy-lain-dev-layout"
  status_line "wofi style" "$HOME/.config/wofi/style.css"
  status_line "starship config" "$HOME/.config/starship.toml"
  status_line "tmux config" "$HOME/.config/tmux/tmux.conf"
  status_line "lazygit config" "$HOME/.config/lazygit/config.yml"
  status_line "fastfetch config" "$HOME/.config/fastfetch/config.jsonc"
  status_line "zed settings" "$HOME/.config/zed/settings.json"
  status_line "gtk3 css" "$HOME/.config/gtk-3.0/gtk.css"
  status_line "gtk4 css" "$HOME/.config/gtk-4.0/gtk.css"
  status_line "typora theme" "$HOME/.config/Typora/themes/lain-wired-i3.css"
  status_line "bat config" "$HOME/.config/bat/config"
  status_line "bat theme" "$HOME/.config/bat/themes/Lain Wired i3.tmTheme"

  local profile count=0
  while IFS= read -r profile; do
    [[ -n "$profile" ]] || continue
    count=$((count + 1))
    status_line "firefox-like userChrome" "$profile/chrome/userChrome.css"
  done < <(browser_profiles)
  (( count > 0 )) || printf 'no   firefox-like profiles found\n'
}

case "$action" in
install)
  install_waybar
  install_menu
  install_dev_layout
  install_wofi
  install_app_configs
  install_firefox_like_profiles
  install_vscode_extension
  restart_apps
  log "Applied $theme_name extras from $theme_dir"
  ;;
uninstall)
  uninstall_waybar
  uninstall_menu
  uninstall_dev_layout
  uninstall_wofi
  uninstall_app_configs
  uninstall_firefox_like_profiles
  uninstall_vscode_extension
  restart_apps
  log "Uninstalled $theme_name extras"
  ;;
status)
  show_status
  ;;
esac
