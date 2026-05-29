#!/usr/bin/env bash
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# title      Citypop Osaka — fork of tokyo-night-tmux
# upstream   https://github.com/janoamaral/tokyo-night-tmux
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$CURRENT_DIR/src"

source "$SCRIPTS_PATH/themes.sh"

# ─── Palette aliases ──────────────────────────────────────────
BG="${THEME[background]}"
FG="${THEME[foreground]}"
BBLACK="${THEME[bblack]}"
BLUE="${THEME[blue]}"
CYAN="${THEME[cyan]}"
GREEN="${THEME[green]}"
YELLOW="${THEME[yellow]}"

# ─── Global styles ────────────────────────────────────────────
tmux set -g status-left-length 80
tmux set -g status-right-length 150
tmux set -g status-style "bg=$BG"
tmux set -g mode-style "fg=${THEME[bgreen]},bg=$BBLACK"
tmux set -g message-style "bg=$BLUE,fg=$BBLACK"
tmux set -g message-command-style "fg=$BLUE,bg=$BBLACK"
tmux set -g popup-border-style "fg=$BLUE"

RESET="#[fg=$FG,bg=$BG,nobold,noitalics,nounderscore,nodim]"

# ─── tokyo-night-tmux options (read from user config) ─────────
TMUX_VARS="$(tmux show -g)"
get_opt() { echo "$TMUX_VARS" | grep "$1" | cut -d' ' -f2; }

window_id_style="$(get_opt '@tokyo-night-tmux_window_id_style')"
pane_id_style="$(get_opt '@tokyo-night-tmux_pane_id_style')"
zoom_id_style="$(get_opt '@tokyo-night-tmux_zoom_id_style')"
terminal_icon="$(get_opt '@tokyo-night-tmux_terminal_icon')"
active_terminal_icon="$(get_opt '@tokyo-night-tmux_active_terminal_icon')"

window_id_style="${window_id_style:-digital}"
pane_id_style="${pane_id_style:-hsquare}"
zoom_id_style="${zoom_id_style:-dsquare}"
terminal_icon="${terminal_icon:-󰆍}"
active_terminal_icon="${active_terminal_icon:-󰆍}"

# ─── Plugin/widget command stubs ──────────────────────────────
PLUG="$HOME/.tmux/plugins"

netspeed_cmd="#($SCRIPTS_PATH/netspeed.sh)"
cmus_cmd="#($SCRIPTS_PATH/music-tmux-statusbar.sh)"
git_cmd="#($SCRIPTS_PATH/git-status.sh #{pane_current_path})"
wb_git_cmd="#($SCRIPTS_PATH/wb-git-status.sh #{pane_current_path} &)"
window_number="#($SCRIPTS_PATH/custom-number.sh #I $window_id_style)"
zoom_number="#($SCRIPTS_PATH/custom-number.sh #P $zoom_id_style)"
datetime_cmd="#($SCRIPTS_PATH/datetime-widget.sh)"
path_cmd="#($SCRIPTS_PATH/path-widget.sh #{pane_current_path})"
battery_cmd="#($SCRIPTS_PATH/battery-widget.sh)"
hostname_cmd="#($SCRIPTS_PATH/hostname-widget.sh)"

pomo_text="#($SCRIPTS_PATH/pomo-text.sh)"
cpu_text="#($PLUG/tmux-cpu/scripts/cpu_percentage.sh)"
ram_text="#($PLUG/tmux-cpu/scripts/ram_percentage.sh)"
disk_text="#($SCRIPTS_PATH/disk-widget.sh)"
weather_text="#($SCRIPTS_PATH/weather-text.sh)"
weather_icon="#($SCRIPTS_PATH/weather-icon.sh)"
# Keep weather cache fresh; suppress plugin's own output to avoid double-render.
weather_refresh="#($PLUG/tmux-weather/scripts/weather.sh >/dev/null 2>&1)"

# ─── Pill builder ─────────────────────────────────────────────
# pill <icon> <value> [trailing]  →  BLUE icon + BBLACK value, both on dark pill.
pill() {
  printf "#[fg=%s,bg=%s,bold] %s #[fg=%s,bg=%s,nobold] %s %s" \
    "$BLUE" "$BBLACK" "$1" \
    "$FG" "$BBLACK" "$2" "$3"
}

POMO_PILL="$(pill '󱎫' "$pomo_text")"
CPU_PILL="$(pill '󰍛' "$cpu_text")"
RAM_PILL="$(pill '󰘚' "$ram_text")"
DISK_PILL="$(pill '󰋊' "$disk_text")"
WEATHER_PILL="$(pill "$weather_icon" "$weather_text" "$weather_refresh")"

# ─── Status LEFT (session pill + menu button) ─────────────────
SESSION_PILL="#[fg=$BBLACK,bg=$BLUE,bold] #{?client_prefix,󰠠 ,#[dim]󰤂 }#[bold,nodim]#(whoami)$hostname_cmd:#S #[default]"
MENU_BUTTON="#[range=user|sess_menu,fg=$BLUE,bg=$BBLACK,bold] 󰍜 #[norange,default]"

tmux set -g status-left "${MENU_BUTTON}${SESSION_PILL}"

# ─── Window status (focused vs unfocused) ─────────────────────
tmux set -g window-status-separator ""
tmux set -g window-status-current-format \
  "$RESET#[fg=$GREEN,bg=$BBLACK] #{?#{==:#{pane_current_command},ssh},󰣀 ,${active_terminal_icon} }#[fg=$FG,bold,nodim]${window_number}#W#[nobold]#{?window_zoomed_flag, $zoom_number,} "
tmux set -g window-status-format \
  "$RESET#[fg=$FG] #{?#{==:#{pane_current_command},ssh},󰣀 ,${terminal_icon} }${RESET}${window_number}#W#[nobold,dim]#{?window_zoomed_flag, $zoom_number,} "

# ─── Status RIGHT row 0: git + system widgets ─────────────────
RIGHT_TOP="${CPU_PILL}${RAM_PILL}${DISK_PILL}${WEATHER_PILL}${battery_cmd}${netspeed_cmd}${cmus_cmd}"
tmux set -g status-right "${wb_git_cmd}${git_cmd}${RIGHT_TOP}"

# ─── Status row 1 (bottom): path + pomo + datetime ────────────
RIGHT_BOTTOM="${POMO_PILL}${datetime_cmd}"
tmux set -g 'status-format[1]' \
  "#[bg=$BG,fg=$FG]${path_cmd}#[align=right,bg=$BG]${RIGHT_BOTTOM}"

# ─── Pane border (transparent so header sits over terminal bg) ─
tmux set -g pane-border-lines heavy
tmux set -g pane-border-style "fg=$BBLACK,bg=default"
tmux set -g pane-active-border-style "fg=$CYAN,bg=default,bold"
tmux set -g pane-border-status top
tmux set -g pane-border-format \
  "#[fg=$BBLACK,bg=default]─#[fg=$FG,bg=default] #{?pane_active,#[fg=$CYAN]●,#[fg=$BBLACK]○} #P #[fg=$BLUE]#{pane_current_command} #[fg=$FG,dim]#{=/24/...:pane_title}#[nodim,fg=$BBLACK,bg=default]─"
