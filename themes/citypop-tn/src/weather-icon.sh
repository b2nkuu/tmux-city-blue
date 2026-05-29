#!/usr/bin/env bash
# Map current weather emoji (cached by tmux-weather) to nf-md icon.
val=$(tmux show-option -gqv "@weather-previous-value" 2>/dev/null)
case "$val" in
  *"☀"*|*"🌞"*)        echo "󰖙" ;;   # sunny
  *"🌤"*)               echo "󰖕" ;;   # partly sunny
  *"⛅"*)               echo "󰖕" ;;   # partly cloudy
  *"🌥"*|*"☁"*)        echo "󰖐" ;;   # cloudy
  *"🌦"*)               echo "󰖗" ;;   # partly rainy
  *"🌧"*)               echo "󰖖" ;;   # rainy
  *"⛈"*)               echo "󰙾" ;;   # thunder rain
  *"🌩"*)               echo "󰖓" ;;   # lightning
  *"❄"*|*"🌨"*)        echo "󰜗" ;;   # snow
  *"🌫"*)               echo "󰖑" ;;   # fog
  *"💨"*|*"🌬"*)       echo "󰖝" ;;   # wind
  *)                    echo "󰖐" ;;   # default cloud
esac
