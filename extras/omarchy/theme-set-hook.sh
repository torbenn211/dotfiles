#!/usr/bin/env bash
set -euo pipefail

theme_name="${1:-}"
[[ -n "$theme_name" ]] || exit 0

theme_dir="$HOME/.config/omarchy/themes/$theme_name"
if [[ ! -d "$theme_dir" && -n "${OMARCHY_PATH:-}" && -d "$OMARCHY_PATH/themes/$theme_name" ]]; then
  theme_dir="$OMARCHY_PATH/themes/$theme_name"
fi

apply_script="$theme_dir/extras/omarchy/apply-extras.sh"
[[ -x "$apply_script" ]] || exit 0

OMARCHY_THEME_DIR="$theme_dir" "$apply_script" install "$theme_name"
