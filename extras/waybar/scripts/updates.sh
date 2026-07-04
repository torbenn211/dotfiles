#!/usr/bin/env bash
set -euo pipefail

source="pacman -Qu"
if command -v checkupdates >/dev/null 2>&1; then
  count=$({ checkupdates 2>/dev/null || true; } | wc -l)
  source="checkupdates"
elif command -v pacman >/dev/null 2>&1; then
  count=$({ pacman -Qu 2>/dev/null || true; } | wc -l)
else
  printf '{"text":"n/a","class":"unavailable","tooltip":"No package update checker found"}\n'
  exit 0
fi

class="clean"
(( count > 0 )) && class="dirty"

printf '{"text":"%s","class":"%s","tooltip":"%s package updates via %s"}\n' "$count" "$class" "$count" "$source"
