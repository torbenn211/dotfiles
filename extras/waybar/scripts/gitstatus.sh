#!/usr/bin/env bash
set -euo pipefail

json_escape() {
  if command -v jq >/dev/null 2>&1; then
    jq -Rs .
  else
    sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | awk '{ printf "\"%s\"", $0 }'
  fi
}

pid=$(hyprctl activewindow -j 2>/dev/null | jq -r '.pid // empty' 2>/dev/null || true)
[[ -n "$pid" ]] || { printf '{"text":"","tooltip":"No focused git repository"}\n'; exit 0; }

cwd=$(readlink "/proc/$pid/cwd" 2>/dev/null || true)
[[ -n "$cwd" ]] || { printf '{"text":"","tooltip":"No process working directory"}\n'; exit 0; }

git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  printf '{"text":"","tooltip":"Focused window is not in a git repository"}\n'
  exit 0
}

branch=$(git -C "$cwd" branch --show-current 2>/dev/null || true)
[[ -n "$branch" ]] || branch="detached"

status=$(git -C "$cwd" status --porcelain 2>/dev/null || true)
class="clean"
suffix=""
if [[ -n "$status" ]]; then
  class="dirty"
  suffix="*"
fi

repo=$(basename "$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$cwd")")
tooltip=$(printf '%s\n%s\n%s' "$repo" "$branch" "${status:-clean}" | json_escape)

printf '{"text":"GIT:%s%s","class":"%s","tooltip":%s}\n' "$branch" "$suffix" "$class" "$tooltip"
