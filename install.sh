#!/usr/bin/env bash
set -euo pipefail

source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
theme_name="${OMARCHY_I3_THEME_NAME:-lain-wired-i3}"
target_dir="$HOME/.config/omarchy/themes/$theme_name"
hook_path="$HOME/.config/omarchy/hooks/theme-set.d/90-lain-wired-i3-extras"
stamp="lain-wired-i3"
assume_yes=false
dry_run=false
reboot_after_install="ask"

has_gum() {
  command -v gum >/dev/null 2>&1
}

title() {
  if has_gum; then
    gum style --border normal --padding "1 2" --border-foreground 196 --foreground 15 "Lain Wired i3 Omarchy TUI"
  else
    printf '\n== Lain Wired i3 Omarchy TUI ==\n'
  fi
}

say() {
  printf '%s\n' "$*"
}

step() {
  printf '[%s] %s\n' "$stamp" "$*"
}

pause() {
  [[ "$assume_yes" == true ]] && return 0
  if has_gum; then
    gum input --placeholder "Press Enter to continue" >/dev/null
  else
    read -r -p "Press Enter to continue " _
  fi
}

confirm() {
  local prompt="$1"
  [[ "$assume_yes" == true ]] && return 0
  if has_gum; then
    gum confirm "$prompt"
  else
    read -r -p "$prompt [y/N] " answer
    [[ "${answer,,}" == "y" || "${answer,,}" == "yes" ]]
  fi
}

choose() {
  local prompt="$1"
  shift
  if has_gum; then
    printf '%s\n' "$@" | gum choose --header "$prompt"
  else
    local options=("$@") index
    say "$prompt"
    for index in "${!options[@]}"; do
      printf '  %s) %s\n' "$((index + 1))" "${options[$index]}"
    done
    read -r -p "> " index
    [[ "$index" =~ ^[0-9]+$ ]] || return 1
    printf '%s\n' "${options[$((index - 1))]}"
  fi
}

run_or_show() {
  if [[ "$dry_run" == true ]]; then
    printf '[dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

chmod_theme_scripts() {
  local base="$1"
  local path
  local files=()

  shopt -s nullglob
  files+=("$base/install.sh")
  files+=("$base/extras/omarchy/"*.sh)
  files+=("$base/extras/waybar/scripts/"*)
  files+=("$base/scripts/"*.sh)

  for path in "${files[@]}"; do
    [[ -f "$path" ]] || continue
    if [[ "$dry_run" == true ]]; then
      printf '[dry-run] chmod +x %s\n' "$path"
    else
      chmod +x "$path"
    fi
  done
}

reboot_system() {
  if command -v systemctl >/dev/null 2>&1; then
    run_or_show systemctl reboot
  else
    run_or_show reboot
  fi
}

offer_reboot() {
  case "$reboot_after_install" in
    yes)
      step "Rebooting now to load the full rice"
      reboot_system
      ;;
    no)
      ;;
    ask)
      if [[ "$assume_yes" == true ]]; then
        step "Skipping reboot; pass --reboot to reboot after a non-interactive install"
        return 0
      fi
      confirm "Reboot now to load the full rice?" || return 0
      reboot_system
      ;;
  esac
}

install_plan() {
  cat <<EOF
This installer will:

1. Copy this repo to:
   $target_dir

2. Register an Omarchy theme-set hook:
   $hook_path

3. Apply the Omarchy theme:
   colors, wallpapers, terminals, Hyprland, Hyprlock, Mako, Walker,
   SwayOSD, Chromium browser color, btop, Helix, Neovim, Obsidian,
   VS Code/VSCodium/Cursor theme metadata.

4. Apply the full rice extras:
   bottom i3-style developer Waybar layout and scripts, project HUD module,
   custom developer workspace launcher, custom Omarchy menu, Wofi style, Starship prompt, tmux, LazyGit,
   Fastfetch, Zed, GTK, Typora, Bat, Firefox-like browser chrome,
   and a local VS Code-compatible theme extension.

5. Create one-time backups next to changed files, ending in:
   .before-$stamp

6. Restart/reload supported running apps when Omarchy commands exist.

7. Offer an optional reboot after install so the full rice can reload cleanly.
EOF
}

uninstall_plan() {
  cat <<EOF
The uninstaller will:

1. Remove the theme-set hook:
   $hook_path

2. If this theme is currently active, try to switch to an installed
   fallback theme before deleting anything.

3. Restore backups for managed files where backups exist:
   Waybar, Waybar scripts, Omarchy menu override, Wofi, Starship,
   tmux, LazyGit, Fastfetch, Zed, GTK, Typora, Bat, developer layout
   command, and Firefox-like browser chrome.

4. Remove managed files that had no previous backup.

5. Remove the local VS Code/VSCodium/Cursor theme extension copies.

6. Remove the installed theme directory:
   $target_dir
EOF
}

copy_theme() {
  step "Preparing theme directory $target_dir"
  run_or_show mkdir -p "$target_dir"

  local item name
  shopt -s dotglob nullglob
  for item in "$source_dir"/*; do
    name="$(basename "$item")"
    case "$name" in
      .git|dist|__pycache__|*.tmp|*.bak|.tmp-*) continue ;;
    esac
    [[ "$(realpath -m "$item")" == "$(realpath -m "$target_dir")" ]] && continue
    step "Copying $name into the Omarchy theme directory"
    if [[ "$dry_run" == true ]]; then
      printf '[dry-run] cp -R %s %s\n' "$item" "$target_dir/"
    else
      rm -rf "$target_dir/$name"
      cp -R "$item" "$target_dir/"
    fi
  done
}

install_hook() {
  step "Installing theme-set hook so extras reapply when the theme is selected"
  if [[ "$dry_run" == true ]]; then
    printf '[dry-run] install -Dm755 %s %s\n' "$target_dir/extras/omarchy/theme-set-hook.sh" "$hook_path"
  else
    install -Dm755 "$target_dir/extras/omarchy/theme-set-hook.sh" "$hook_path"
  fi
}

apply_theme() {
  if command -v omarchy-theme-set >/dev/null 2>&1; then
    step "Running omarchy-theme-set $theme_name"
    run_or_show omarchy-theme-set "$theme_name"
  else
    step "omarchy-theme-set was not found; applying extras only"
    if [[ "$dry_run" == true ]]; then
      printf '[dry-run] OMARCHY_THEME_DIR=%s %s install %s\n' "$target_dir" "$target_dir/extras/omarchy/apply-extras.sh" "$theme_name"
    else
      OMARCHY_THEME_DIR="$target_dir" "$target_dir/extras/omarchy/apply-extras.sh" install "$theme_name"
    fi
  fi
}

install_full() {
  title
  install_plan
  confirm "Install the full Lain Wired i3 rice?" || return 0

  step "Ensuring local scripts are executable"
  chmod_theme_scripts "$source_dir"
  copy_theme
  step "Ensuring installed scripts are executable"
  chmod_theme_scripts "$target_dir"
  install_hook
  apply_theme

  step "Install complete"
  offer_reboot
}

current_theme() {
  cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null || true
}

fallback_theme() {
  local candidate
  if command -v omarchy-theme-list >/dev/null 2>&1; then
    for candidate in matte-black tokyo-night gruvbox catppuccin rose-pine white; do
      if omarchy-theme-list 2>/dev/null | grep -Fxq "$candidate"; then
        printf '%s\n' "$candidate"
        return 0
      fi
    done
    omarchy-theme-list 2>/dev/null | grep -Fvx "$theme_name" | head -n 1
  fi
}

remove_hook() {
  if [[ -e "$hook_path" ]]; then
    step "Removing theme-set hook $hook_path"
    run_or_show rm -f "$hook_path"
  fi
}

switch_from_theme_if_active() {
  [[ "$(current_theme)" == "$theme_name" ]] || return 0
  command -v omarchy-theme-set >/dev/null 2>&1 || {
    step "Theme is active, but omarchy-theme-set is unavailable; leaving current copy in place"
    return 0
  }

  local fallback
  fallback="$(fallback_theme || true)"
  if [[ -n "$fallback" ]]; then
    step "Current theme is $theme_name; switching to fallback theme $fallback"
    run_or_show omarchy-theme-set "$fallback"
  else
    step "No fallback theme found; current theme copy will remain until you switch manually"
  fi
}

uninstall_extras() {
  local script="$target_dir/extras/omarchy/apply-extras.sh"
  [[ -x "$script" ]] || script="$source_dir/extras/omarchy/apply-extras.sh"

  if [[ -x "$script" ]]; then
    step "Restoring/removing managed rice extras"
    if [[ "$dry_run" == true ]]; then
      printf '[dry-run] OMARCHY_THEME_DIR=%s %s uninstall %s\n' "$target_dir" "$script" "$theme_name"
    else
      OMARCHY_THEME_DIR="$target_dir" "$script" uninstall "$theme_name"
    fi
  fi
}

remove_theme_dir() {
  [[ -d "$target_dir" ]] || return 0

  case "$(realpath -m "$target_dir")" in
    "$(realpath -m "$HOME/.config/omarchy/themes")"/*)
      step "Removing installed theme directory $target_dir"
      run_or_show rm -rf "$target_dir"
      ;;
    *)
      step "Refusing to remove unexpected path: $target_dir"
      ;;
  esac
}

uninstall_full() {
  title
  uninstall_plan
  confirm "Uninstall Lain Wired i3 and restore backups?" || return 0

  remove_hook
  switch_from_theme_if_active
  uninstall_extras
  remove_theme_dir

  step "Uninstall complete"
}

show_status() {
  title
  say "Theme name: $theme_name"
  say "Source:     $source_dir"
  say "Target:     $target_dir"
  say ""

  if [[ -d "$target_dir" ]]; then
    say "core theme: installed"
  else
    say "core theme: missing"
  fi

  if [[ -e "$hook_path" ]]; then
    say "hook:       installed"
  else
    say "hook:       missing"
  fi

  say "current:    $(current_theme || true)"
  say ""

  local script="$target_dir/extras/omarchy/apply-extras.sh"
  [[ -x "$script" ]] || script="$source_dir/extras/omarchy/apply-extras.sh"
  if [[ -x "$script" ]]; then
    OMARCHY_THEME_DIR="$target_dir" "$script" status "$theme_name"
  fi
}

preview_install() {
  title
  install_plan
  pause
}

preview_uninstall() {
  title
  uninstall_plan
  pause
}

main_menu() {
  while true; do
    title
    choice="$(choose "Choose an action" \
      "Install full rice" \
      "Uninstall and restore backups" \
      "Show install plan" \
      "Show uninstall plan" \
      "Show status" \
      "Exit")" || exit 0

    case "$choice" in
      "Install full rice") install_full; pause ;;
      "Uninstall and restore backups") uninstall_full; pause ;;
      "Show install plan") preview_install ;;
      "Show uninstall plan") preview_uninstall ;;
      "Show status") show_status; pause ;;
      "Exit") exit 0 ;;
    esac
  done
}

usage() {
  cat <<EOF
Usage: ./install.sh [action] [options]

Actions:
  --install       Install the full rice
  --uninstall     Uninstall and restore backups
  --status        Show installed status
  --preview       Show install plan

Options:
  --yes           Do not prompt
  --dry-run       Print actions without changing files
  --reboot        Reboot after a successful install
  --no-reboot     Do not offer a reboot after install
  --help          Show this help

No action opens the TUI.
EOF
}

action=""
while (($#)); do
  case "$1" in
    --install) action="install" ;;
    --uninstall) action="uninstall" ;;
    --status) action="status" ;;
    --preview) action="preview" ;;
    --yes|-y) assume_yes=true ;;
    --dry-run) dry_run=true ;;
    --reboot) reboot_after_install="yes" ;;
    --no-reboot) reboot_after_install="no" ;;
    --help|-h) usage; exit 0 ;;
    *) say "Unknown argument: $1"; usage; exit 1 ;;
  esac
  shift
done

case "$action" in
  install) install_full ;;
  uninstall) uninstall_full ;;
  status) show_status ;;
  preview) preview_install ;;
  "") main_menu ;;
esac
