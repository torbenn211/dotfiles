#!/usr/bin/env bash
set -euo pipefail

to_celsius() {
  local value="$1"
  [[ "$value" =~ ^-?[0-9]+$ ]] || return 1
  if (( value > 1000 || value < -1000 )); then
    printf '%s\n' "$((value / 1000))"
  else
    printf '%s\n' "$value"
  fi
}

nvidia_temp() {
  command -v nvidia-smi >/dev/null 2>&1 || return 1
  local value
  value=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n 1 | tr -dc '0-9' || true)
  [[ "$value" =~ ^[0-9]+$ ]] || return 1
  printf '%s\n' "$value"
}

hwmon_gpu_temp() {
  local dir name input label value best_input=""
  for dir in /sys/class/hwmon/hwmon*; do
    [[ -r "$dir/name" ]] || continue
    name=$(cat "$dir/name" 2>/dev/null || true)
    case "$name" in
      amdgpu|nouveau|nvidia|i915|xe) ;;
      *) continue ;;
    esac

    for input in "$dir"/temp*_input; do
      [[ -r "$input" ]] || continue
      label=$(cat "${input%_input}_label" 2>/dev/null || true)
      case "${label,,}" in
        edge|junction|gpu|temp1|"") best_input="$input"; break ;;
        mem|memory) [[ -n "$best_input" ]] || best_input="$input" ;;
        *) [[ -n "$best_input" ]] || best_input="$input" ;;
      esac
    done

    [[ -n "$best_input" ]] || continue
    value=$(cat "$best_input" 2>/dev/null || true)
    to_celsius "$value" && return 0
  done

  return 1
}

temp=$(nvidia_temp || hwmon_gpu_temp || true)
if [[ -z "$temp" ]]; then
  printf '{"text":"n/a","class":"unavailable","tooltip":"GPU temperature source unavailable"}\n'
  exit 0
fi

class="normal"
(( temp >= 85 )) && class="critical"
(( temp >= 70 && temp < 85 )) && class="warning"

printf '{"text":"%sC","class":"%s","tooltip":"GPU temperature: %sC"}\n' "$temp" "$class" "$temp"
