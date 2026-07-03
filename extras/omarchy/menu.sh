#!/usr/bin/env bash
# Lain Wired i3 menu override for ~/.config/omarchy/extensions/menu.sh.

menu() {
  local prompt="$1"
  local options="$2"
  local extra="$3"
  local preselect="$4"

  read -r -a args <<<"$extra"

  if [[ -n $preselect ]]; then
    local index
    index=$(echo -e "$options" | grep -nxF "$preselect" | cut -d: -f1)
    [[ -n $index ]] && args+=("-c" "$index")
  fi

  echo -e "$options" | omarchy-launch-walker --dmenu --width 430 --minheight 1 --maxheight 560 -p "[$prompt]" "${args[@]}" 2>/dev/null
}

launch_files() {
  if command -v nautilus >/dev/null 2>&1 && command -v uwsm-app >/dev/null 2>&1; then
    uwsm-app -- nautilus "$HOME" >/dev/null 2>&1 &
  elif command -v nautilus >/dev/null 2>&1; then
    nautilus "$HOME" >/dev/null 2>&1 &
  elif command -v gtk-launch >/dev/null 2>&1; then
    gtk-launch org.gnome.Nautilus.desktop >/dev/null 2>&1 &
  else
    xdg-open "$HOME" >/dev/null 2>&1 &
  fi
}

show_main_menu() {
  case $(menu "wm" "run apps\ndev layout\nterminal\ntmux\nbrowser\nfiles\ncapture\ntoggle\nstyle\nsetup\ninstall\nremove\nupdate\nkeys\nabout\npower") in
  *"run apps"*) walker -p "run:" ;;
  *"dev layout"*) "$HOME/.local/bin/omarchy-lain-dev-layout" ;;
  *terminal*) omarchy-launch-terminal ;;
  *tmux*) omarchy-launch-terminal-tmux ;;
  *browser*) omarchy-launch-browser ;;
  *files*) launch_files ;;
  *capture*) show_capture_menu ;;
  *toggle*) show_toggle_menu ;;
  *style*) show_style_menu ;;
  *setup*) show_setup_menu ;;
  *install*) show_install_menu ;;
  *remove*) show_remove_menu ;;
  *update*) show_update_menu ;;
  *keys*) omarchy-menu-keybindings ;;
  *about*) show_about ;;
  *power*) show_system_menu ;;
  esac
}

show_style_menu() {
  case $(menu "style" "theme\nwallpaper\nfont\nbar bottom\nbar top\nsharp corners\nround corners\nhypr look\nlock look\nwaybar config\nwalker config") in
  *theme*) show_theme_menu ;;
  *wallpaper*) show_background_menu ;;
  *font*) show_font_menu ;;
  *"bar bottom"*) omarchy-style-waybar-position bottom ;;
  *"bar top"*) omarchy-style-waybar-position top ;;
  *"sharp corners"*) omarchy-style-corners sharp ;;
  *"round corners"*) omarchy-style-corners round ;;
  *"hypr look"*) open_in_editor "$(hypr_config_file looknfeel)" ;;
  *"lock look"*) open_in_editor ~/.config/hypr/hyprlock.conf ;;
  *"waybar config"*) open_in_editor ~/.config/waybar/config.jsonc && omarchy-restart-waybar ;;
  *"walker config"*) open_in_editor ~/.config/walker/config.toml && omarchy-restart-walker ;;
  *) show_main_menu ;;
  esac
}

show_system_menu() {
  local options="lock\nscreensaver"
  ! omarchy-toggle-enabled suspend-off && options="$options\nsuspend"
  omarchy-hibernation-available && options="$options\nhibernate"
  options="$options\nlogout\nreboot\nshutdown"

  case $(menu "power" "$options") in
  *screensaver*) omarchy-launch-screensaver force ;;
  *lock*) omarchy-system-lock ;;
  *suspend*) systemctl suspend ;;
  *hibernate*) systemctl hibernate ;;
  *logout*) omarchy-system-logout ;;
  *reboot*) omarchy-system-reboot ;;
  *shutdown*) omarchy-system-shutdown ;;
  *) show_main_menu ;;
  esac
}
