#!/usr/bin/env bash
# Render CPU load as a neon block-char bar (1-8 cells).
# Reads cpu_percentage from tmux-cpu plugin, outputs colored blocks.

set -e

raw=$(~/.tmux/plugins/tmux-cpu/scripts/cpu_percentage.sh 2>/dev/null || echo "0%")
pct=${raw%.*}
pct=${pct%\%}
pct=${pct:-0}

# Map 0-100 → 0-8 cells
cells=$(( pct * 8 / 100 ))
[ "$cells" -gt 8 ] && cells=8
[ "$cells" -lt 0 ] && cells=0

# Color by load
if [ "$pct" -lt 40 ]; then
  color="#6ee7b7"   # seafoam
elif [ "$pct" -lt 75 ]; then
  color="#fcd34d"   # sand
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
