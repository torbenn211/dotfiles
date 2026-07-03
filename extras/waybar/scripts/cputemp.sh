#!/usr/bin/env bash
set -euo pipefail

read_temp() {
  local file value
  for file in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp*_input; do
    [[ -r "$file" ]] || continue
    value=$(cat "$file" 2>/dev/null || true)
    [[ "$value" =~ ^[0-9]+$ ]] || continue
    if (( value > 1000 )); then
      echo $((value / 1000))
    else
      echo "$value"
    fi
    return
  done
  echo ""
}

temp_c=$(read_temp)
if [[ -z "$temp_c" ]]; then
  printf '{"text":"","tooltip":"No CPU temperature sensor found"}\n'
  exit 0
fi

class="normal"
(( temp_c > 80 )) && class="critical"
(( temp_c > 65 && temp_c <= 80 )) && class="warning"

printf '{"text":"%sC","class":"%s","tooltip":"CPU Temp: %sC"}\n' "$temp_c" "$class" "$temp_c"
