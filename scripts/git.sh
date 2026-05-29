#!/usr/bin/env bash
# Print git branch + dirty marker for current pane cwd.
# Output empty if not in a repo. Designed for tmux status-bar.

set -e

cwd="${1:-$PWD}"
cd "$cwd" 2>/dev/null || exit 0

branch=$(git -C "$cwd" symbolic-ref --quiet --short HEAD 2>/dev/null \
  || git -C "$cwd" rev-parse --short HEAD 2>/dev/null) \
  || exit 0

if [ -z "$branch" ]; then
  exit 0
fi

# dirty check: any uncommitted change
if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
  dirty="●"
else
  dirty="○"
fi

printf " %s %s" "$branch" "$dirty"
