#!/usr/bin/env bash
# tmux-city-blue: save the current session as a NAMED snapshot, decoupled
# from the live session name so it can be loaded into any other session.
#
# Usage: snapshot_save.sh [name]
# If no name is given, a timestamped one is generated.
# Output: $XDG_DATA_HOME/tmux-city-blue/snapshots/<name>.tmux

set -euo pipefail

raw_name="${1:-}"
if [ -z "$raw_name" ]; then
  raw_name="snapshot-$(date +%Y%m%d-%H%M%S)"
fi

# Sanitize: collapse spaces/slashes, keep alnum . _ -
NAME=$(printf '%s' "$raw_name" | tr ' /' '__' | tr -cd '[:alnum:]._-')
if [ -z "$NAME" ]; then
  tmux display-message "󰕒  invalid snapshot name"
  exit 1
fi

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux-city-blue/snapshots"
mkdir -p "$DATA_DIR"

OUT="$DATA_DIR/${NAME}.tmux"
TMP="$(mktemp "${TMPDIR:-/tmp}/tmux-city-blue.XXXXXX")"
trap 'rm -f "$TMP"' EXIT

SESSION=$(tmux display-message -p '#S')
TAB=$'\t'

{
  printf 'snapshot%s%s\n' "$TAB" "$NAME"

  tmux list-windows -t "=$SESSION" \
    -F "#{window_index}${TAB}#{window_name}${TAB}#{window_active}${TAB}#{window_layout}" \
    | while IFS="$TAB" read -r w_idx w_name w_active w_layout; do
        printf 'window%s%s%s%s%s%s%s%s\n' \
          "$TAB" "$w_idx" "$TAB" "$w_name" "$TAB" "$w_active" "$TAB" "$w_layout"

        tmux list-panes -t "=$SESSION:$w_idx" \
          -F "#{pane_index}${TAB}#{pane_active}${TAB}#{pane_current_path}${TAB}#{pane_current_command}" \
          | while IFS="$TAB" read -r p_idx p_active p_path p_cmd; do
              printf 'pane%s%s%s%s%s%s%s%s%s%s\n' \
                "$TAB" "$w_idx" \
                "$TAB" "$p_idx" \
                "$TAB" "$p_active" \
                "$TAB" "$p_path" \
                "$TAB" "$p_cmd"
            done
      done
} > "$TMP"

mv "$TMP" "$OUT"
trap - EXIT

tmux display-message "󰕒  snapshot '$NAME' saved → ${OUT/#$HOME/~}"
