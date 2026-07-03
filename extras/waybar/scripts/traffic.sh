#!/usr/bin/env bash
set -euo pipefail

cache_file="${XDG_RUNTIME_DIR:-/tmp}/waybar_traffic_cache"

get_interface() {
  ip route get 1.1.1.1 2>/dev/null | awk '{
    for (i = 1; i <= NF; i++) {
      if ($i == "dev") {
        print $(i + 1)
        exit
      }
    }
  }'
}

format_speed() {
  awk -v bytes="$1" 'BEGIN {
    if (bytes >= 1048576) printf "%.1fM", bytes / 1048576;
    else if (bytes >= 1024) printf "%.1fK", bytes / 1024;
    else printf "%dB", bytes;
  }'
}

interface=$(get_interface)
if [[ -z "$interface" ]]; then
  printf '{"text":"DOWN 0B UP 0B","tooltip":"No active network interface"}\n'
  exit 0
fi

rx=$(cat "/sys/class/net/$interface/statistics/rx_bytes" 2>/dev/null || echo 0)
tx=$(cat "/sys/class/net/$interface/statistics/tx_bytes" 2>/dev/null || echo 0)
now=$(date +%s)

old_rx=$rx
old_tx=$tx
old_time=$now
if [[ -f "$cache_file" ]]; then
  read -r old_rx old_tx old_time < "$cache_file" || true
fi

elapsed=$((now - old_time))
if (( elapsed > 0 )); then
  rx_speed=$(((rx - old_rx) / elapsed))
  tx_speed=$(((tx - old_tx) / elapsed))
else
  rx_speed=0
  tx_speed=0
fi

printf '%s %s %s\n' "$rx" "$tx" "$now" > "$cache_file"

rx_fmt=$(format_speed "$rx_speed")
tx_fmt=$(format_speed "$tx_speed")
printf '{"text":"DOWN %s UP %s","tooltip":"%s: down %s/s | up %s/s"}\n' "$rx_fmt" "$tx_fmt" "$interface" "$rx_fmt" "$tx_fmt"
