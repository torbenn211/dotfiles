#!/usr/bin/env bash
set -euo pipefail

root="${1:-${OMARCHY_I3_DEV_ROOT:-$HOME}}"
ws_shell="${OMARCHY_I3_DEV_WS_SHELL:-1}"
ws_editor="${OMARCHY_I3_DEV_WS_EDITOR:-2}"
ws_web="${OMARCHY_I3_DEV_WS_WEB:-3}"
ws_monitor="${OMARCHY_I3_DEV_WS_MONITOR:-4}"
dev_url="${OMARCHY_I3_DEV_URL:-}"

quote() {
  local value="${1//\'/\'\\\'\'}"
  printf "'%s'" "$value"
}

run_cmd() {
  printf 'bash -lc %s' "$(quote "$1")"
}

launch_on_workspace() {
  local workspace="$1"
  local command="$2"

  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch exec "[workspace $workspace silent] $command" >/dev/null 2>&1 || \
      hyprctl dispatch exec "$command" >/dev/null 2>&1 || true
  else
    bash -lc "$command" >/dev/null 2>&1 &
  fi
}

root_q="$(quote "$root")"
url_q="$(quote "$dev_url")"

shell_cmd=$(run_cmd "cd $root_q 2>/dev/null || cd \"\$HOME\"; if command -v omarchy-launch-terminal-tmux >/dev/null 2>&1; then omarchy-launch-terminal-tmux; elif command -v xdg-terminal-exec >/dev/null 2>&1; then xdg-terminal-exec; else exec \"\${TERMINAL:-foot}\"; fi")
editor_cmd=$(run_cmd "cd $root_q 2>/dev/null || cd \"\$HOME\"; if command -v omarchy-launch-editor >/dev/null 2>&1; then omarchy-launch-editor $root_q; elif command -v code >/dev/null 2>&1; then code $root_q; elif command -v nvim >/dev/null 2>&1 && command -v xdg-terminal-exec >/dev/null 2>&1; then xdg-terminal-exec nvim $root_q; else exec \"\${EDITOR:-vi}\" $root_q; fi")
web_cmd=$(run_cmd "if [[ -n $url_q ]]; then if command -v omarchy-launch-browser >/dev/null 2>&1; then omarchy-launch-browser $url_q; else xdg-open $url_q; fi; elif command -v omarchy-launch-browser >/dev/null 2>&1; then omarchy-launch-browser; else xdg-open about:blank; fi")
monitor_cmd=$(run_cmd "cd $root_q 2>/dev/null || cd \"\$HOME\"; if command -v omarchy-launch-or-focus-tui >/dev/null 2>&1; then omarchy-launch-or-focus-tui btop; elif command -v xdg-terminal-exec >/dev/null 2>&1; then xdg-terminal-exec btop; else btop; fi")

launch_on_workspace "$ws_shell" "$shell_cmd"
sleep 0.15
launch_on_workspace "$ws_editor" "$editor_cmd"
sleep 0.15
launch_on_workspace "$ws_web" "$web_cmd"
sleep 0.15
launch_on_workspace "$ws_monitor" "$monitor_cmd"

if command -v hyprctl >/dev/null 2>&1; then
  hyprctl dispatch workspace "$ws_shell" >/dev/null 2>&1 || true
fi
