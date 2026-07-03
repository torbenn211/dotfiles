# Theme Scripts

Small maintenance helpers for this Omarchy theme.

```bash
scripts/check-theme.sh
```

Validates required files, Bash syntax, JSON syntax, and temporary build artifacts.
It also checks executable bits, script line endings, and UTF-8 BOM markers.

```bash
scripts/palette.sh
```

Prints the theme palette as terminal color blocks.

```bash
scripts/apply-local.sh
scripts/apply-local.sh --dry-run
```

Reapplies the local checkout through the main TUI installer.

```bash
scripts/package-theme.sh
```

Creates `dist/omarchy-lain-wired-i3-theme.tar.gz` for sharing or archiving.
