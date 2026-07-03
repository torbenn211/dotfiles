#!/usr/bin/env bash
set -euo pipefail

read_temp() {
  local dir name file label value fallback=""

  for dir in /sys/class/hwmon/hwmon*; do
    [[ -r "$dir/name" ]] || continue
    name=$(cat "$dir/name" 2>/dev/null || true)
    case "$name" in
      coretemp|k10temp|zenpower|cpu_thermal|acpitz|thinkpad) ;;
      *) continue ;;
    esac

    for file in "$dir"/temp*_input; do
      [[ -r "$file" ]] || continue
      label=$(cat "${file%_input}_label" 2>/dev/null || true)
      case "${label,,}" in
        "package id 0"|tctl|tdie|cpu|composite|"")
          value=$(cat "$file" 2>/dev/null || true)
          [[ "$value" =~ ^[0-9]+$ ]] || continue
          (( value > 1000 )) && value=$((value / 1000))
          echo "$value"
          return
          ;;
        *)
          [[ -n "$fallback" ]] || fallback="$file"
          ;;
      esac
    done
  done

  if [[ -n "$fallback" ]]; then
    value=$(cat "$fallback" 2>/dev/null || true)
    [[ "$value" =~ ^[0-9]+$ ]] || value=""
    [[ -n "$value" ]] && (( value > 1000 )) && value=$((value / 1000))
    echo "$value"
    return
  fi

  for file in /sys/class/thermal/thermal_zone*/temp; do
    [[ -r "$file" ]] || continue
    value=$(cat "$file" 2>/dev/null || true)
    [[ "$value" =~ ^[0-9]+$ ]] || continue
    (( value > 1000 )) && value=$((value / 1000))
    echo "$value"
    return
  done

  echo ""
}

temp_c=$(read_temp)
if [[ -z "$temp_c" ]]; then
  printf '{"text":"n/a","class":"unavailable","tooltip":"No CPU temperature sensor found"}\n'
  exit 0
fi

class="normal"
(( temp_c > 80 )) && class="critical"
(( temp_c > 65 && temp_c <= 80 )) && class="warning"

printf '{"text":"%sC","class":"%s","tooltip":"CPU temperature: %sC"}\n' "$temp_c" "$class" "$temp_c"
