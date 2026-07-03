#!/usr/bin/env bash
set -euo pipefail

todo_file="${OMARCHY_I3_TODO_FILE:-$HOME/todo.txt}"

json_escape() {
  if command -v jq >/dev/null 2>&1; then
    jq -Rs .
  else
    sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | awk '{ printf "\"%s\"", $0 }'
  fi
}

if [[ ! -f "$todo_file" ]]; then
  printf '{"text":"todo 0","tooltip":"No todo file"}\n'
  exit 0
fi

items=$(grep -v '^[[:space:]]*$' "$todo_file" | grep -v '^[[:space:]]*#' || true)
count=$(printf '%s\n' "$items" | grep -c . || true)

if (( count == 0 )); then
  printf '{"text":"todo 0","tooltip":"No todos"}\n'
  exit 0
fi

tooltip=$(printf '%s\n' "$items" | head -n 5 | nl -ba -s'. ')
if (( count > 5 )); then
  tooltip="${tooltip}"$'\n'"... and $((count - 5)) more"
fi

escaped=$(printf '%s' "$tooltip" | json_escape)
printf '{"text":"todo %s","tooltip":%s}\n' "$count" "$escaped"
