#!/usr/bin/env bash
out=$(~/.tmux/plugins/tmux-pomodoro-plus/scripts/pomodoro.sh status 2>/dev/null)
out="${out# }"
out="${out% }"
[ -z "$out" ] && exit 0

if [[ "$out" =~ ^(.*[^0-9:])?([0-9]+):([0-9]{2})$ ]]; then
  prefix="${BASH_REMATCH[1]}"
  mm=$((10#${BASH_REMATCH[2]}))
  ss=$((10#${BASH_REMATCH[3]}))
  total=$(( mm * 60 + ss ))
  hh=$(( total / 3600 ))
  mm_out=$(( (total % 3600) / 60 ))
  if (( total % 60 != 0 )); then
    mm_out=$(( mm_out + 1 ))
    if (( mm_out == 60 )); then mm_out=0; hh=$(( hh + 1 )); fi
  fi
  printf "%s%02d:%02d" "$prefix" "$hh" "$mm_out"
else
  printf "%s" "$out"
fi
