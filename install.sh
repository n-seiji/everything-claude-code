#!/usr/bin/env bash
# install.sh — Install claude settings, commands, and rules.
#
# Usage:
#   ./install.sh                    → settings + commands only
#   ./install.sh <language> [...]   → settings + commands + rules
#
# Examples:
#   ./install.sh
#   ./install.sh typescript
#   ./install.sh typescript python golang
#
# Installs:
#   1. Settings   → ~/.claude/settings.json (symlink)
#   2. Plugins    → ~/.claude/plugins/config.json (symlink),
#                    ~/.claude/plugins/installed_plugins.json (copy if missing)
#   3. Local conf → ~/.claude/settings.local.json (copy from example if missing)
#   4. Commands   → ~/.claude/commands/ (symlinks)
#   5. Rules      → ~/.claude/rules/ (copy, requires language argument)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# ── Helpers ──────────────────────────────────────────────────────

link_file() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  if [ -f "$dest" ] && [ ! -L "$dest" ]; then
    echo "  backup: $dest -> ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi
  [ -L "$dest" ] && rm "$dest"
  ln -s "$src" "$dest"
  echo "  link: $dest -> $src"
}

copy_if_missing() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  # Remove broken symlinks
  [ -L "$dest" ] && rm "$dest"
  if [ -e "$dest" ]; then
    echo "  skip: $dest (already exists)"
    return
  fi
  cp "$src" "$dest"
  echo "  copy: $src -> $dest"
}

# ── 1. Settings ──────────────────────────────────────────────────

echo "Installing Claude settings..."
link_file "$SCRIPT_DIR/.claude/settings.json" "$CLAUDE_DIR/settings.json"

# ── 2. Plugins ───────────────────────────────────────────────────

echo "Installing plugins config..."
link_file "$SCRIPT_DIR/.claude/plugins/config.json" "$CLAUDE_DIR/plugins/config.json"
copy_if_missing "$SCRIPT_DIR/.claude/plugins/installed_plugins.json" "$CLAUDE_DIR/plugins/installed_plugins.json"

# ── 3. Local settings ───────────────────────────────────────────

echo "Installing local settings..."
copy_if_missing "$SCRIPT_DIR/.claude/settings.local.json.example" "$CLAUDE_DIR/settings.local.json"

# ── 4. Commands ──────────────────────────────────────────────────

COMMANDS_SRC="$SCRIPT_DIR/commands"
COMMANDS_DEST="$CLAUDE_DIR/commands"

echo "Installing commands..."
mkdir -p "$COMMANDS_DEST"
for cmd in "$COMMANDS_SRC"/*.md; do
  [ -f "$cmd" ] || continue
  name="$(basename "$cmd")"
  dest="$COMMANDS_DEST/$name"
  [ -L "$dest" ] && rm "$dest"
  if [ -f "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "${dest}.bak"
  fi
  ln -s "$cmd" "$dest"
done
echo "  linked: $COMMANDS_SRC/*.md -> $COMMANDS_DEST/"

# ── 5. Rules (optional) ─────────────────────────────────────────

if [[ $# -gt 0 ]]; then
  RULES_DIR="$SCRIPT_DIR/rules"
  DEST_DIR="${CLAUDE_RULES_DIR:-$CLAUDE_DIR/rules}"

  echo "Installing common rules -> $DEST_DIR/common/"
  mkdir -p "$DEST_DIR/common"
  cp -r "$RULES_DIR/common/." "$DEST_DIR/common/"

  for lang in "$@"; do
    lang_dir="$RULES_DIR/$lang"
    if [[ ! -d "$lang_dir" ]]; then
      echo "Warning: rules/$lang/ does not exist, skipping." >&2
      continue
    fi
    echo "Installing $lang rules -> $DEST_DIR/$lang/"
    mkdir -p "$DEST_DIR/$lang"
    cp -r "$lang_dir/." "$DEST_DIR/$lang/"
  done
fi

echo ""
echo "Done."
