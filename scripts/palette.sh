#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
colors_file="$root/colors.toml"

hex_to_rgb() {
  local hex="${1#\#}"
  printf '%d;%d;%d' "0x${hex:0:2}" "0x${hex:2:2}" "0x${hex:4:2}"
}

printf 'Lain Wired i3 palette\n\n'

while IFS='=' read -r key value; do
  key="${key//[[:space:]]/}"
  value="${value//[\"[:space:]]/}"
  [[ -n "$key" && "$key" != \#* && "$value" == \#* ]] || continue

  rgb="$(hex_to_rgb "$value")"
  printf '\033[48;2;%sm  \033[0m %-22s %s\n' "$rgb" "$key" "$value"
done < "$colors_file"
