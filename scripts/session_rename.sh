#!/usr/bin/env bash
# city-blue: rename the current tmux session and migrate its snapshot file.
#
# Usage: session_rename.sh <new-name>
# Renames the live session via `tmux rename-session`, then moves any
# saved snapshot at $XDG_DATA_HOME/city-blue/sessions/<old>.tmux to
# match the new name so save/restore stays consistent.

set -euo pipefail

NEW="${1:-}"
if [ -z "$NEW" ]; then
  tmux display-message "󰑕  rename: missing new name"
  exit 1
fi

_XDG="${XDG_DATA_HOME:-$HOME/.local/share}"
DATA_DIR="$_XDG/city-blue/sessions"

OLD=$(tmux display-message -p '#S')

if [ "$OLD" = "$NEW" ]; then
  exit 0
fi

tmux rename-session -t "$OLD" "$NEW"

OLD_FILE="$DATA_DIR/${OLD}.tmux"
NEW_FILE="$DATA_DIR/${NEW}.tmux"

if [ -f "$OLD_FILE" ]; then
  if [ -e "$NEW_FILE" ]; then
    tmux display-message "󰑕  renamed (snapshot kept: ${NEW}.tmux already exists)"
  else
    mv "$OLD_FILE" "$NEW_FILE"
    tmux display-message "󰑕  renamed → $NEW (snapshot migrated)"
  fi
else
  tmux display-message "󰑕  renamed → $NEW"
fi
