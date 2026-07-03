#!/usr/bin/env bash
set -euo pipefail

if ! command -v nvidia-smi >/dev/null 2>&1; then
  printf '{"text":"","tooltip":"No NVIDIA GPU temperature source found"}\n'
  exit 0
fi

temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -n 1 || true)
if [[ ! "$temp" =~ ^[0-9]+$ ]]; then
  printf '{"text":"","tooltip":"GPU temperature unavailable"}\n'
  exit 0
fi

class="normal"
(( temp > 80 )) && class="critical"
(( temp > 65 && temp <= 80 )) && class="warning"

printf '{"text":"%sC","class":"%s","tooltip":"GPU Temp: %sC"}\n' "$temp" "$class" "$temp"
