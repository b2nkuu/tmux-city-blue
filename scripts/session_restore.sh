#!/usr/bin/env bash
# city-blue: restore a saved tmux session snapshot.
#
# Reads $XDG_DATA_HOME/city-blue/sessions/<name>.tmux files.
# If multiple files exist, lets the user pick via fzf popup.
# If the target session already exists, switches the client to it
# (does not destroy the live session). Otherwise creates it from scratch.

set -euo pipefail

_XDG="${XDG_DATA_HOME:-$HOME/.local/share}"
DATA_DIR="$_XDG/city-blue/sessions"
_LEGACY="$_XDG/tmux-city-blue/sessions"
[ ! -d "$DATA_DIR" ] && [ -d "$_LEGACY" ] && { mkdir -p "$(dirname "$DATA_DIR")"; mv "$_LEGACY" "$DATA_DIR"; }

shopt -s nullglob
files=("$DATA_DIR"/*.tmux)
if [ ${#files[@]} -eq 0 ]; then
  tmux display-message "󰦛  no saved sessions in $DATA_DIR"
  exit 0
fi

if [ ${#files[@]} -eq 1 ]; then
  FILE="${files[0]}"
else
  LIST="$(mktemp "${TMPDIR:-/tmp}/city-blue.list.XXXXXX")"
  PICK="$(mktemp "${TMPDIR:-/tmp}/city-blue.pick.XXXXXX")"
  trap 'rm -f "$LIST" "$PICK"' EXIT
  printf '%s\n' "${files[@]##*/}" | sed 's/\.tmux$//' > "$LIST"
  tmux display-popup -E -w 60% -h 60% \
    "fzf --reverse --prompt='restore session > ' < '$LIST' > '$PICK'" || exit 0
  pick="$(cat "$PICK")"
  [ -n "$pick" ] || exit 0
  FILE="$DATA_DIR/${pick}.tmux"
fi

[ -f "$FILE" ] || { tmux display-message "󰦛  not found: $FILE"; exit 1; }

# Whitelist of commands worth re-launching on restore.
relaunch() {
  case "$1" in
    nvim|vim|claude|ssh|mosh|mosh-client|lazygit|htop|btop|k9s|lf|yazi|less|man) return 0 ;;
    *) return 1 ;;
  esac
}

SESSION=""
created_session=0
declare -A win_first_pane_done
declare -A win_layout
declare -A win_active
pane_active_target=""

TAB=$'\t'

while IFS="$TAB" read -ra fields; do
  kind="${fields[0]}"
  case "$kind" in
    session)
      SESSION="${fields[1]}"
      if tmux has-session -t "=$SESSION" 2>/dev/null; then
        tmux switch-client -t "=$SESSION" 2>/dev/null || tmux attach-session -t "=$SESSION"
        tmux display-message "󰦛  session '$SESSION' already running — switched"
        exit 0
      fi
      tmux new-session -d -s "$SESSION" -n '__bootstrap__'
      created_session=1
      ;;
    window)
      w_idx="${fields[1]}"
      w_name="${fields[2]}"
      w_active="${fields[3]}"
      w_layout="${fields[4]}"
      if ! tmux list-windows -t "=$SESSION" -F '#{window_index}' | grep -qx "$w_idx"; then
        tmux new-window -d -t "=$SESSION:$w_idx" -n "$w_name"
      else
        tmux rename-window -t "=$SESSION:$w_idx" "$w_name"
      fi
      win_layout["$w_idx"]="$w_layout"
      [ "$w_active" = "1" ] && win_active["$w_idx"]=1
      ;;
    pane)
      w_idx="${fields[1]}"
      p_idx="${fields[2]}"
      p_active="${fields[3]}"
      p_path="${fields[4]}"
      p_cmd="${fields[5]:-}"
      target="=$SESSION:$w_idx"

      if [ -z "${win_first_pane_done[$w_idx]:-}" ]; then
        first_pane=$(tmux list-panes -t "$target" -F '#{pane_index}' | head -1)
        tmux send-keys -t "$target.$first_pane" "cd ${p_path@Q} && clear" C-m
        if relaunch "$p_cmd"; then
          tmux send-keys -t "$target.$first_pane" "$p_cmd" C-m
        fi
        win_first_pane_done[$w_idx]=1
        pane_ref="$target.$first_pane"
      else
        tmux split-window -t "$target" -c "$p_path"
        if relaunch "$p_cmd"; then
          tmux send-keys -t "$target" "$p_cmd" C-m
        fi
        pane_ref="$target"
      fi

      [ "$p_active" = "1" ] && pane_active_target="$pane_ref"
      ;;
  esac
done < "$FILE"

# Apply window layouts (best-effort; layout strings reference pane indices,
# which match because we recreated panes in saved order).
for w_idx in "${!win_layout[@]}"; do
  tmux select-layout -t "=$SESSION:$w_idx" "${win_layout[$w_idx]}" 2>/dev/null || true
done

# Drop the bootstrap window if it's still around (only the case when no real
# window claimed index 0 / the bootstrap name).
if tmux list-windows -t "=$SESSION" -F '#{window_name}' 2>/dev/null \
    | grep -qx '__bootstrap__'; then
  tmux kill-window -t "=$SESSION:__bootstrap__" 2>/dev/null || true
fi

# Focus the originally-active window and pane.
for w_idx in "${!win_active[@]}"; do
  tmux select-window -t "=$SESSION:$w_idx" 2>/dev/null || true
done
[ -n "$pane_active_target" ] && tmux select-pane -t "$pane_active_target" 2>/dev/null || true

if [ "$created_session" = "1" ]; then
  if [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "=$SESSION"
  else
    tmux attach-session -t "=$SESSION"
  fi
fi

tmux display-message "󰦛  restored '$SESSION' from ${FILE/#$HOME/~}"
