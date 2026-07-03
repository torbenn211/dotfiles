#!/usr/bin/env bash
set -euo pipefail

nvidia_usage() {
  command -v nvidia-smi >/dev/null 2>&1 || return 1
  local value
  value=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -n 1 | tr -dc '0-9' || true)
  [[ "$value" =~ ^[0-9]+$ ]] || return 1
  printf '%s\n' "$value"
}

sysfs_busy() {
  local file value
  for file in /sys/class/drm/card*/device/gpu_busy_percent; do
    [[ -r "$file" ]] || continue
    value=$(cat "$file" 2>/dev/null || true)
    [[ "$value" =~ ^[0-9]+$ ]] || continue
    printf '%s\n' "$value"
    return 0
  done
  return 1
}

intel_usage() {
  command -v intel_gpu_top >/dev/null 2>&1 || return 1
  command -v jq >/dev/null 2>&1 || return 1
  local value
  value=$(timeout 2 intel_gpu_top -J -s 1000 -o - 2>/dev/null | jq -r '."engines"."Render/3D/0".busy // ."engines"."Render/3D".busy // empty' | head -n 1 || true)
  value=${value%.*}
  [[ "$value" =~ ^[0-9]+$ ]] || return 1
  printf '%s\n' "$value"
}

usage=$(nvidia_usage || sysfs_busy || intel_usage || true)
if [[ -z "$usage" ]]; then
  printf '{"text":"n/a","class":"unavailable","tooltip":"GPU usage source unavailable"}\n'
  exit 0
fi

printf '{"text":"%s%%","class":"normal","tooltip":"GPU usage: %s%%"}\n' "$usage" "$usage"
