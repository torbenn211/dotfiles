#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
name="${1:-omarchy-lain-wired-i3-theme}"
dist="$root/dist"
archive="$dist/$name.tar.gz"
python_cmd=()

chmod +x \
  "$root/install.sh" \
  "$root"/extras/omarchy/*.sh \
  "$root"/extras/waybar/scripts/* \
  "$root"/scripts/*.sh

mkdir -p "$dist"
rm -f "$archive"

if command -v python3 >/dev/null 2>&1 && python3 -c 'import tarfile' >/dev/null 2>&1; then
  python_cmd=(python3)
elif command -v python >/dev/null 2>&1 && python -c 'import tarfile' >/dev/null 2>&1; then
  python_cmd=(python)
elif command -v py >/dev/null 2>&1 && py -3 -c 'import tarfile' >/dev/null 2>&1; then
  python_cmd=(py -3)
fi

if (( ${#python_cmd[@]} > 0 )); then
  "${python_cmd[@]}" - "$root" "$archive" <<'PY'
import fnmatch
import os
import sys
import tarfile

root, archive = sys.argv[1], sys.argv[2]
skip_dirs = {".git", "dist", "__pycache__"}
skip_patterns = ("*.tmp", "*.bak")

def should_skip(rel):
    parts = rel.split("/")
    return (
        any(part in skip_dirs or part.startswith(".tmp-") for part in parts)
        or any(fnmatch.fnmatch(rel, pattern) for pattern in skip_patterns)
    )

def is_executable(rel):
    return (
        rel == "install.sh"
        or (rel.startswith("extras/omarchy/") and rel.endswith(".sh"))
        or rel.startswith("extras/waybar/scripts/")
        or (rel.startswith("scripts/") and rel.endswith(".sh"))
    )

with tarfile.open(archive, "w:gz") as tar:
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [name for name in dirnames if name not in skip_dirs and not name.startswith(".tmp-")]
        rel_dir = os.path.relpath(dirpath, root).replace(os.sep, "/")
        if rel_dir != "." and not should_skip(rel_dir):
            info = tar.gettarinfo(dirpath, arcname=f"./{rel_dir}")
            info.mode = 0o755
            tar.addfile(info)

        for filename in sorted(filenames):
            path = os.path.join(dirpath, filename)
            rel = os.path.relpath(path, root).replace(os.sep, "/")
            if should_skip(rel):
                continue

            info = tar.gettarinfo(path, arcname=f"./{rel}")
            if info.isfile():
                info.mode = 0o755 if is_executable(rel) else 0o644
                with open(path, "rb") as handle:
                    tar.addfile(info, handle)
            else:
                tar.addfile(info)
PY
else
  tar \
    --exclude='.git' \
    --exclude='dist' \
    --exclude='*.tmp' \
    --exclude='*.bak' \
    --exclude='__pycache__' \
    --exclude='.tmp-*' \
    -czf "$archive" \
    -C "$root" .
fi

printf 'wrote %s\n' "$archive"
