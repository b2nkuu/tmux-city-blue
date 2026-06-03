#!/usr/bin/env bash
# city-blue: snapshot current tmux session to a plain-text file.
#
# Output: $XDG_DATA_HOME/city-blue/sessions/<session>.tmux
# Format: tab-separated records, one per line.
#   session<TAB><name>
#   window<TAB><idx><TAB><name><TAB><active><TAB><layout>
#   pane<TAB><win_idx><TAB><pane_idx><TAB><active><TAB><cwd><TAB><cmd>

set -euo pipefail

_XDG="${XDG_DATA_HOME:-$HOME/.local/share}"
DATA_DIR="$_XDG/city-blue/sessions"
_LEGACY="$_XDG/tmux-city-blue/sessions"
[ ! -d "$DATA_DIR" ] && [ -d "$_LEGACY" ] && { mkdir -p "$(dirname "$DATA_DIR")"; mv "$_LEGACY" "$DATA_DIR"; }
mkdir -p "$DATA_DIR"

SESSION=$(tmux display-message -p '#S')
OUT="$DATA_DIR/${SESSION}.tmux"
TMP="$(mktemp "${TMPDIR:-/tmp}/city-blue.XXXXXX")"
trap 'rm -f "$TMP"' EXIT

TAB=$'\t'

{
  printf 'session%s%s\n' "$TAB" "$SESSION"

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

tmux display-message "󰆓  saved session '$SESSION' → ${OUT/#$HOME/~}"
