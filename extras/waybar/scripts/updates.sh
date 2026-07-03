#!/usr/bin/env bash
set -euo pipefail

count=0
if command -v checkupdates >/dev/null 2>&1; then
  count=$(checkupdates 2>/dev/null | wc -l)
fi

class="clean"
(( count > 0 )) && class="dirty"

printf '{"text":"%s","class":"%s","tooltip":"%s package updates"}\n' "$count" "$class" "$count"
