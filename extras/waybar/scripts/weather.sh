#!/usr/bin/env bash
set -euo pipefail

location="${OMARCHY_I3_WEATHER_LOCATION:-}"
path="${location// /+}"
url="https://wttr.in/${path}?format=%t|%C|%w|%h|%P"

weather_data=$(curl -fsS --max-time 6 "$url" 2>/dev/null || true)
if [[ -z "$weather_data" ]]; then
  printf '{"text":"weather ?","tooltip":"Failed to fetch weather"}\n'
  exit 0
fi

IFS='|' read -r temp condition wind humidity pressure <<< "$weather_data"
temp=${temp#+}

printf '{"text":"%s %s","tooltip":"Location: %s\\nTemp: %s\\nCondition: %s\\nWind: %s\\nHumidity: %s\\nPressure: %s"}\n' \
  "$temp" "$condition" "${location:-auto}" "$temp" "$condition" "$wind" "$humidity" "$pressure"
