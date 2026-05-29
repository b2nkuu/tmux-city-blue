#!/usr/bin/env bash
# Print git branch badge for tmux status-bar (city-blue palette).
# High-contrast orange badge on dark bg so the branch never blends in.
# Output empty when cwd is not a git repo.

set -e

cwd="${1:-$PWD}"
cd "$cwd" 2>/dev/null || exit 0

branch=$(git -C "$cwd" symbolic-ref --quiet --short HEAD 2>/dev/null \
  || git -C "$cwd" rev-parse --short HEAD 2>/dev/null) || exit 0
[ -z "$branch" ] && exit 0

if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
  dirty="●"
else
  dirty="○"
fi

# city-blue palette
ROW="#1a0b2e"   # BG0
BG="#ff7f3f"    # ORG (high-contrast orange)
FG="#1a0b2e"    # BG0 (dark text on orange)
PL_RL=$(printf '\xee\x82\xb6')   # rounded left cap
PL_RR=$(printf '\xee\x82\xb4')   # rounded right cap
BR=$(printf '\xee\x82\xa0')      # powerline branch glyph

printf '#[fg=%s,bg=%s]%s#[bg=%s,fg=%s,bold] %s %s %s #[fg=%s,bg=%s]%s' \
  "$BG" "$ROW" "$PL_RL" "$BG" "$FG" "$BR" "$branch" "$dirty" "$BG" "$ROW" "$PL_RR"
