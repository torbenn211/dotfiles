#!/usr/bin/env bash
set -euo pipefail

json_escape() {
  if command -v jq >/dev/null 2>&1; then
    jq -Rs .
  else
    sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' | tr -d '\n' | awk '{ printf "\"%s\"", $0 }'
  fi
}

active_cwd() {
  local pid cwd
  pid=$(hyprctl activewindow -j 2>/dev/null | jq -r '.pid // empty' 2>/dev/null || true)
  [[ -n "$pid" ]] || return 1
  cwd=$(readlink "/proc/$pid/cwd" 2>/dev/null || true)
  [[ -n "$cwd" ]] || return 1
  printf '%s\n' "$cwd"
}

find_root() {
  local dir="$1"
  while [[ "$dir" != "/" && -n "$dir" ]]; do
    for marker in Makefile makefile CMakeLists.txt Cargo.toml go.mod package.json pyproject.toml mix.exs pom.xml build.zig; do
      [[ -e "$dir/$marker" ]] && { printf '%s\n' "$dir"; return 0; }
    done
    dir=$(dirname "$dir")
  done
  return 1
}

cwd=$(active_cwd || true)
if [[ -z "$cwd" ]]; then
  printf '{"text":"","class":"none","tooltip":"No focused project"}\n'
  exit 0
fi

root=$(find_root "$cwd" || true)
if [[ -z "$root" ]]; then
  printf '{"text":"","class":"none","tooltip":"No known project manifest"}\n'
  exit 0
fi

text="SRC"
class="native"
if [[ -e "$root/Cargo.toml" ]]; then text="CARGO"; class="native"; fi
if [[ -e "$root/Makefile" || -e "$root/makefile" ]]; then text="MAKE"; class="native"; fi
if [[ -e "$root/CMakeLists.txt" ]]; then text="CMAKE"; class="native"; fi
if [[ -e "$root/go.mod" ]]; then text="GO"; class="native"; fi
if [[ -e "$root/build.zig" ]]; then text="ZIG"; class="native"; fi
if [[ -e "$root/pyproject.toml" ]]; then text="PY"; class="script"; fi
if [[ -e "$root/package.json" ]]; then text="JS"; class="web"; fi
if [[ -e "$root/mix.exs" ]]; then text="BEAM"; class="vm"; fi
if [[ -e "$root/pom.xml" ]]; then text="JVM"; class="vm"; fi

repo=$(basename "$root")
tooltip=$(printf '%s\n%s' "$repo" "$root" | json_escape)
printf '{"text":"%s","class":"%s","tooltip":%s}\n' "$text" "$class" "$tooltip"
