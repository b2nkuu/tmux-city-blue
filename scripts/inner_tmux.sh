#!/usr/bin/env bash
# Launch the city-blue "inner" tmux inside the current pane.
# Uses a dedicated socket (-L inner) so it does not touch the outer session.
#
# Usage:
#   ~/.tmux/scripts/inner_tmux.sh           # attach/create session "tabs"
#   ~/.tmux/scripts/inner_tmux.sh review    # attach/create session "review"

set -euo pipefail

CONF="${INNER_TMUX_CONF:-$HOME/.tmux/share/inner.tmux.conf}"
SESSION="${1:-tabs}"

if [[ ! -f "$CONF" ]]; then
  printf 'inner_tmux: config not found: %s\n' "$CONF" >&2
  exit 1
fi

exec tmux -L inner -f "$CONF" new-session -A -s "$SESSION"
