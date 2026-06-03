#!/usr/bin/env bash
# city-blue: delete one or more saved session snapshots via fzf popup.
# Use Tab in fzf to multi-select before Enter.
#
# Only removes the snapshot file under $XDG_DATA_HOME/city-blue/sessions.
# Live tmux sessions are left untouched — use the "kill session" menu
# entry for that.

set -euo pipefail

_XDG="${XDG_DATA_HOME:-$HOME/.local/share}"
DATA_DIR="$_XDG/city-blue/sessions"

shopt -s nullglob
files=("$DATA_DIR"/*.tmux)
if [ ${#files[@]} -eq 0 ]; then
  tmux display-message "󰆴  no saved sessions to delete"
  exit 0
fi

LIST="$(mktemp "${TMPDIR:-/tmp}/city-blue.list.XXXXXX")"
PICK="$(mktemp "${TMPDIR:-/tmp}/city-blue.pick.XXXXXX")"
trap 'rm -f "$LIST" "$PICK"' EXIT

printf '%s\n' "${files[@]##*/}" | sed 's/\.tmux$//' > "$LIST"

tmux display-popup -E -w 60% -h 60% \
  "fzf --multi --reverse --prompt='delete session snapshot (Tab=multi) > ' \
       --header='Enter to delete, Esc to cancel' \
       < '$LIST' > '$PICK'" || exit 0

[ -s "$PICK" ] || exit 0

count=0
while IFS= read -r name; do
  [ -z "$name" ] && continue
  rm -f "$DATA_DIR/${name}.tmux"
  count=$((count + 1))
done < "$PICK"

tmux display-message "󰆴  deleted $count session snapshot(s)"
