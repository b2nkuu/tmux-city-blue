#!/usr/bin/env bash
# Render RAM load as a neon block-char bar (1-8 cells).

set -e

raw=$(~/.tmux/scripts/ram.sh 2>/dev/null || echo "0%")
pct=${raw%\%}
pct=${pct:-0}

cells=$(( pct * 8 / 100 ))
[ "$cells" -gt 8 ] && cells=8
[ "$cells" -lt 0 ] && cells=0

if [ "$pct" -lt 50 ]; then
  color="#7dd3fc"   # sky
elif [ "$pct" -lt 80 ]; then
  color="#5eead4"   # aqua
else
  color="#fb7185"   # coral
fi

bar=""
for i in $(seq 1 8); do
  if [ "$i" -le "$cells" ]; then
    bar="${bar}█"
  else
    bar="${bar}░"
  fi
done

printf "#[fg=%s]%s" "$color" "$bar"
