#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

printf 'Applying local Lain Wired i3 theme from:\n%s\n\n' "$root"

if [[ "${1:-}" == "--dry-run" ]]; then
  exec "$root/install.sh" --install --dry-run --yes
fi

exec "$root/install.sh" --install --yes
