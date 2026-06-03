#!/usr/bin/env bash
# city-blue: delete one or more saved snapshots via fzf popup.
# Use Tab in fzf to multi-select before Enter.

set -euo pipefail

_XDG="${XDG_DATA_HOME:-$HOME/.local/share}"
DATA_DIR="$_XDG/city-blue/snapshots"
_LEGACY="$_XDG/tmux-city-blue/snapshots"
[ ! -d "$DATA_DIR" ] && [ -d "$_LEGACY" ] && { mkdir -p "$(dirname "$DATA_DIR")"; mv "$_LEGACY" "$DATA_DIR"; }

shopt -s nullglob
files=("$DATA_DIR"/*.tmux)
if [ ${#files[@]} -eq 0 ]; then
  tmux display-message "󰆴  no snapshots to delete"
  exit 0
fi

LIST="$(mktemp "${TMPDIR:-/tmp}/city-blue.list.XXXXXX")"
PICK="$(mktemp "${TMPDIR:-/tmp}/city-blue.pick.XXXXXX")"
trap 'rm -f "$LIST" "$PICK"' EXIT

printf '%s\n' "${files[@]##*/}" | sed 's/\.tmux$//' > "$LIST"

tmux display-popup -E -w 60% -h 60% \
  "fzf --multi --reverse --prompt='delete snapshot (Tab=multi) > ' \
       --header='Enter to delete, Esc to cancel' \
       < '$LIST' > '$PICK'" || exit 0

[ -s "$PICK" ] || exit 0

count=0
while IFS= read -r name; do
  [ -z "$name" ] && continue
  rm -f "$DATA_DIR/${name}.tmux"
  count=$((count + 1))
done < "$PICK"

tmux display-message "󰆴  deleted $count snapshot(s)"
