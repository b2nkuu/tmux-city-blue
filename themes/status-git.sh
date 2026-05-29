#!/usr/bin/env bash
# Emits orange git segment when inside a repo, else just cyan→bg0 closing arrow.
# Keeps status-left clean: no dangling "-" / no empty segment.
PATH_DIR="${1:-$PWD}"
PL_L=$(printf '\xee\x82\xb0')   #
BR=$(printf '\xee\x82\xa0')     #

branch=$(cd "$PATH_DIR" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
  dirty=""
  if ! git -C "$PATH_DIR" diff --quiet 2>/dev/null || ! git -C "$PATH_DIR" diff --cached --quiet 2>/dev/null; then
    dirty="*"
  fi
  printf '#[fg=#ff7f3f,bg=#4ddbff]%s#[bg=#ff7f3f,fg=#1a0b2e,bold] %s %s%s #[bg=#1a0b2e,fg=#ff7f3f]%s' \
    "$PL_L" "$BR" "$branch" "$dirty" "$PL_L"
else
  printf '#[bg=#1a0b2e,fg=#4ddbff]%s' "$PL_L"
fi
