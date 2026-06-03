#!/usr/bin/env bash
# city-blue: load a snapshot into the live session.
# The snapshot's first window replaces the active window (kills the other
# panes, respawns the active one, then splits to match). Any further
# snapshot windows are appended as new windows. All panes use the active
# pane's current cwd as the base; the snapshot's saved cwd is ignored.

set -euo pipefail

_XDG="${XDG_DATA_HOME:-$HOME/.local/share}"
DATA_DIR="$_XDG/city-blue/snapshots"
_LEGACY="$_XDG/tmux-city-blue/snapshots"
[ ! -d "$DATA_DIR" ] && [ -d "$_LEGACY" ] && { mkdir -p "$(dirname "$DATA_DIR")"; mv "$_LEGACY" "$DATA_DIR"; }

shopt -s nullglob
files=("$DATA_DIR"/*.tmux)
if [ ${#files[@]} -eq 0 ]; then
  tmux display-message "󰇚  no snapshots in $DATA_DIR"
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
    "fzf --reverse --prompt='load snapshot > ' < '$LIST' > '$PICK'" || exit 0
  pick="$(cat "$PICK")"
  [ -n "$pick" ] || exit 0
  FILE="$DATA_DIR/${pick}.tmux"
fi

[ -f "$FILE" ] || { tmux display-message "󰇚  not found: $FILE"; exit 1; }

SESSION=$(tmux display-message -p '#S')
CURRENT_WIN=$(tmux display-message -p '#I')
ACTIVE_PANE=$(tmux display-message -p '#P')
BASE_CWD=$(tmux display-message -p '#{pane_current_path}')

launch_for() {
  case "$1" in
    nvim|vim|claude|ssh|mosh|mosh-client|lazygit|htop|btop|k9s|lf|yazi|less|man)
      printf '%s\n' "$1" ;;
    tmux)
      printf '%s\n' "$HOME/.tmux/scripts/inner_tmux.sh" ;;
    *) return 1 ;;
  esac
}

declare -A new_win
declare -A saved_layout
declare -A win_first_pane_done
first_window=1
surviving_pane=""

TAB=$'\t'

while IFS="$TAB" read -ra fields; do
  kind="${fields[0]}"
  case "$kind" in
    window)
      saved_idx="${fields[1]}"
      w_name="${fields[2]}"
      w_layout="${fields[4]}"
      if [ "$first_window" = "1" ]; then
        # Kill every non-active pane. tmux renumbers panes after kill, so
        # re-query the surviving pane's index instead of trusting the old one.
        while IFS= read -r pi; do
          [ "$pi" = "$ACTIVE_PANE" ] && continue
          tmux kill-pane -t "=$SESSION:$CURRENT_WIN.$pi" 2>/dev/null || true
        done < <(tmux list-panes -t "=$SESSION:$CURRENT_WIN" -F '#{pane_index}' | sort -rn)
        surviving_pane=$(tmux list-panes -t "=$SESSION:$CURRENT_WIN" -F '#{pane_index}' | head -1)
        tmux rename-window -t "=$SESSION:$CURRENT_WIN" "$w_name"
        new_win[$saved_idx]="$CURRENT_WIN"
        first_window=0
      else
        created=$(tmux new-window -d -P -F '#{window_index}' \
          -t "=$SESSION:" -n "$w_name" -c "$BASE_CWD")
        new_win[$saved_idx]="$created"
      fi
      saved_layout[$saved_idx]="$w_layout"
      ;;
    pane)
      saved_w_idx="${fields[1]}"
      p_path="${fields[4]}"
      p_cmd="${fields[5]:-}"
      target_w="${new_win[$saved_w_idx]:-}"
      [ -n "$target_w" ] || continue
      target="=$SESSION:$target_w"

      if [ -z "${win_first_pane_done[$saved_w_idx]:-}" ]; then
        if [ -n "$surviving_pane" ] && [ "$target_w" = "$CURRENT_WIN" ]; then
          tmux respawn-pane -k -c "$BASE_CWD" \
            -t "=$SESSION:$CURRENT_WIN.$surviving_pane" 2>/dev/null || true
          if cmd_str=$(launch_for "$p_cmd"); then
            tmux send-keys -t "=$SESSION:$CURRENT_WIN.$surviving_pane" \
              "$cmd_str" C-m
          fi
          surviving_pane=""
        else
          first_pane=$(tmux list-panes -t "$target" -F '#{pane_index}' | head -1)
          tmux send-keys -t "$target.$first_pane" "cd ${BASE_CWD@Q} && clear" C-m
          if cmd_str=$(launch_for "$p_cmd"); then
            tmux send-keys -t "$target.$first_pane" "$cmd_str" C-m
          fi
        fi
        win_first_pane_done[$saved_w_idx]=1
      else
        tmux split-window -t "$target" -c "$BASE_CWD"
        if cmd_str=$(launch_for "$p_cmd"); then
          tmux send-keys -t "$target" "$cmd_str" C-m
        fi
      fi
      ;;
  esac
done < "$FILE"

for saved_idx in "${!saved_layout[@]}"; do
  new_idx="${new_win[$saved_idx]}"
  tmux select-layout -t "=$SESSION:$new_idx" "${saved_layout[$saved_idx]}" 2>/dev/null || true
done

tmux display-message "󰇚  loaded ${FILE##*/}"
