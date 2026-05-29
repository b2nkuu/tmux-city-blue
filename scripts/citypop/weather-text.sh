#!/usr/bin/env bash
# Strip leading weather emoji + leading plus sign from cached value.
val=$(tmux show-option -gqv "@weather-previous-value" 2>/dev/null)
clean=$(echo -n "$val" | sed -E 's/^[^+0-9-]*//; s/^\+//')
echo -n "$clean"
