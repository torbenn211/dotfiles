#!/usr/bin/env bash
set -euo pipefail

if ! command -v nvidia-smi >/dev/null 2>&1; then
  printf '{"text":"","tooltip":"No NVIDIA GPU usage source found"}\n'
  exit 0
fi

usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n 1 || true)
usage=${usage%%.*}
if [[ ! "$usage" =~ ^[0-9]+$ ]]; then
  printf '{"text":"","tooltip":"GPU usage unavailable"}\n'
  exit 0
fi

printf '{"text":"%s%%","tooltip":"GPU Usage: %s%%"}\n' "$usage" "$usage"
