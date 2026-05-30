#!/usr/bin/env bash
# Strip leading weather emoji + leading plus sign from cached value.
# tmux-weather caches the raw wttr.in response, which on API failure
# becomes "render failed: ... [lat,lon][...][view=...]". Detect that
# and render "n/a" instead of leaking template fragments to the bar.
val=$(tmux show-option -gqv "@weather-previous-value" 2>/dev/null)
if [[ -z "$val" || "$val" == *"render failed"* ]]; then
  echo -n "n/a"
  exit 0
fi
clean=$(echo -n "$val" | sed -E 's/^[^+0-9-]*//; s/^\+//')
echo -n "$clean"
