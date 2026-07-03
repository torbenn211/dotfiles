#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

failures=0

find_tool() {
  if [[ -x /usr/bin/find ]]; then
    printf '%s\n' /usr/bin/find
    return 0
  fi

  command -v find
}

sort_tool() {
  if [[ -x /usr/bin/sort ]]; then
    printf '%s\n' /usr/bin/sort
    return 0
  fi

  command -v sort
}

find_bin="$(find_tool)"
sort_bin="$(sort_tool)"

check() {
  local label="$1"
  shift
  printf 'check: %s\n' "$label"
  if ! "$@"; then
    printf 'failed: %s\n' "$label" >&2
    failures=$((failures + 1))
  fi
}

check_bash() {
  local file status
  status=0
  while IFS= read -r file; do
    if ! bash -n "$file"; then
      status=1
    fi
  done < <("$find_bin" . \
    \( -path './.git' -o -path './dist' -o -path './.tmp-*' \) -prune -o \
    -type f -name '*.sh' -print | "$sort_bin")
  return "$status"
}

check_json() {
  local file
  local -a parser=()
  if command -v python3 >/dev/null 2>&1 && python3 -c 'import json' >/dev/null 2>&1; then
    parser=(python3)
  elif command -v python >/dev/null 2>&1 && python -c 'import json' >/dev/null 2>&1; then
    parser=(python)
  elif command -v py >/dev/null 2>&1 && py -3 -c 'import json' >/dev/null 2>&1; then
    parser=(py -3)
  fi

  (( ${#parser[@]} > 0 )) || {
    printf 'skip: no python json parser found\n'
    return 0
  }

  local status
  status=0
  while IFS= read -r file; do
    if ! "${parser[@]}" -m json.tool "$file" >/dev/null; then
      status=1
    fi
  done < <("$find_bin" . \
    \( -path './.git' -o -path './dist' -o -path './.tmp-*' \) -prune -o \
    -type f \( -name '*.json' -o -name '*.jsonc' \) -print | "$sort_bin")
  return "$status"
}

check_required_files() {
  local required=(
    colors.toml
    alacritty.toml
    foot.ini
    ghostty.conf
    kitty.conf
    btop.theme
    hyprland.lua
    hyprlock.conf
    waybar.css
    walker.css
    mako.ini
    swayosd.css
    vscode.json
    preview.png
    backgrounds/lain1.png
    install.sh
    extras/omarchy/branding/about.txt
    extras/omarchy/branding/screensaver.txt
    extras/omarchy/apply-extras.sh
    extras/waybar/config.jsonc
  )

  local file
  for file in "${required[@]}"; do
    [[ -e "$file" ]] || {
      printf 'missing: %s\n' "$file" >&2
      return 1
    }
  done
}

check_executable_bits() {
  local file status
  status=0

  local required=(
    install.sh
    extras/omarchy/apply-extras.sh
    extras/omarchy/dev-layout.sh
    extras/omarchy/menu.sh
    extras/omarchy/theme-set-hook.sh
    scripts/apply-local.sh
    scripts/check-theme.sh
    scripts/package-theme.sh
    scripts/palette.sh
  )

  shopt -s nullglob
  required+=(extras/waybar/scripts/*)

  for file in "${required[@]}"; do
    [[ -f "$file" ]] || continue
    if [[ ! -x "$file" ]]; then
      printf 'not executable: %s\n' "$file" >&2
      status=1
    fi
  done

  return "$status"
}

check_no_bom() {
  local file bytes status
  status=0

  while IFS= read -r file; do
    bytes="$(LC_ALL=C head -c 3 "$file" | od -An -tx1 | tr -d ' \n')"
    if [[ "$bytes" == "efbbbf" ]]; then
      printf 'utf-8 bom: %s\n' "$file" >&2
      status=1
    fi
  done < <("$find_bin" . \
    \( -path './.git' -o -path './dist' -o -path './.tmp-*' \) -prune -o \
    -type f \( \
      -name '*.sh' -o -name '*.py' -o -name '*.toml' -o -name '*.ini' -o -name '*.conf' -o \
      -name '*.css' -o -name '*.json' -o -name '*.jsonc' -o -name '*.lua' -o -name '*.theme' -o \
      -name '*.yml' -o -name '*.tmTheme' -o -name '*.md' -o -name '*.rgb' -o -name '.gitignore' \
    \) -print | "$sort_bin")

  return "$status"
}

check_script_line_endings() {
  local file status
  status=0

  while IFS= read -r file; do
    if LC_ALL=C grep -q $'\r' "$file"; then
      printf 'crlf line endings: %s\n' "$file" >&2
      status=1
    fi
  done < <("$find_bin" . \
    \( -path './.git' -o -path './dist' -o -path './.tmp-*' \) -prune -o \
    -type f -name '*.sh' -print | "$sort_bin")

  return "$status"
}

check_no_temp_files() {
  local found
  found="$("$find_bin" . \
    \( -path './.git' -o -path './dist' \) -prune -o \
    \( -name '__pycache__' -o -name '*.tmp' -o -name '*.bak' -o -name '.tmp-*' \) -print -quit)"
  [[ -z "$found" ]]
}

check "required files" check_required_files
check "executable bits" check_executable_bits
check "bash syntax" check_bash
check "script line endings" check_script_line_endings
check "json syntax" check_json
check "utf-8 bom markers" check_no_bom
check "temporary files" check_no_temp_files

if (( failures > 0 )); then
  printf '\n%s check(s) failed\n' "$failures" >&2
  exit 1
fi

printf '\nall checks passed\n'
