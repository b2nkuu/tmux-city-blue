# city-blue — per-project tmux wrapper (zsh).
# Source from ~/.zshrc:   source /path/to/city-blue/share/city-blue.zsh
#
# Bare `tmux`:
#   - one tmux server per project (own -L socket)
#   - session named after project root basename
#   - tmux-resurrect dir scoped to project, keyed by directory inode
#     (so renaming or moving the folder does NOT lose saved state on the
#     same filesystem)
#
# `tmux <args>` falls through to the real binary unchanged.

tmux() {
  if [ $# -gt 0 ]; then
    command tmux "$@"
    return
  fi

  local root display id dir legacy

  root="$(git -C "$PWD" rev-parse --show-toplevel 2>/dev/null)"
  [ -n "$root" ] || root="$PWD"
  display="${root##*/}"

  # Stable identifier: inode of the project root. Survives renames on the
  # same FS. Falls back to basename if stat is unavailable.
  if id="$(stat -f '%i' "$root" 2>/dev/null)"; then
    :
  elif id="$(stat -c '%i' "$root" 2>/dev/null)"; then
    :
  else
    id="$display"
  fi

  dir="$HOME/.local/share/tmux/resurrect/$id"
  mkdir -p "$dir"

  # Migration: if this project used the old basename-keyed wrapper, copy
  # its resurrect snapshots into the new inode-keyed dir on first run.
  legacy="$HOME/.local/share/tmux/resurrect/$display"
  if [ "$legacy" != "$dir" ] && [ -d "$legacy" ] \
     && [ -z "$(ls -A "$dir" 2>/dev/null)" ]; then
    cp -R "$legacy"/. "$dir"/ 2>/dev/null || true
  fi

  RESURRECT_DIR="$dir" command tmux -L "$id" new-session -A -s "$display"
}
