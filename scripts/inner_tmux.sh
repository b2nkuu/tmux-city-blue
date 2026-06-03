#!/usr/bin/env bash
# Launch the city-blue "inner" tmux inside the current pane.
# Uses a dedicated socket (-L inner) so it does not touch the outer session.
#
# Session name = project root basename (git toplevel, else $PWD).
# Pass an arg to override.
#
# Usage:
#   ~/.tmux/scripts/inner_tmux.sh           # session per project
#   ~/.tmux/scripts/inner_tmux.sh review    # session "review"

set -euo pipefail

CONF="${INNER_TMUX_CONF:-$HOME/.tmux/share/inner.tmux.conf}"

if [[ ! -f "$CONF" ]]; then
  printf 'inner_tmux: config not found: %s\n' "$CONF" >&2
  exit 1
fi

if [[ $# -gt 0 ]]; then
  SESSION="$1"
else
  ROOT="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null || true)"
  [[ -n "$ROOT" ]] || ROOT="$PWD"
  SESSION="${ROOT##*/}"
fi

exec tmux -L inner -f "$CONF" new-session -A -s "$SESSION" -c "$PWD"
