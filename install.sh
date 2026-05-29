#!/usr/bin/env bash
# Install tmux-city-blue by symlinking this repo into $HOME.
# Existing real files/dirs are backed up with a timestamp suffix.
# Existing symlinks are replaced silently.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

log()  { printf '\033[1;36m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }

backup_if_real() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    local backup="${target}.bak-${STAMP}"
    log "backup ${target} -> ${backup}"
    mv "$target" "$backup"
  fi
}

link() {
  local src="$1" dst="$2"
  backup_if_real "$dst"
  ln -sfn "$src" "$dst"
  log "linked ${dst} -> ${src}"
}

mkdir -p "$HOME/.tmux"

link "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf"
link "$REPO_DIR/conf.d"    "$HOME/.tmux/conf.d"
link "$REPO_DIR/scripts"   "$HOME/.tmux/scripts"
link "$REPO_DIR/themes"    "$HOME/.tmux/themes"

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  log "installing tpm -> ${TPM_DIR}"
  git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  log "tpm already present: ${TPM_DIR}"
fi

cat <<'EOF'

[install] done.

Next steps:
  1. Start or attach tmux:        tmux new -s main
  2. Reload config:               tmux source ~/.tmux.conf
  3. Install plugins (TPM):       press prefix + I  (default prefix: C-b)

Notes:
  - Tested on macOS. Some scripts use pbcopy / osascript / battery name
    "InternalBattery-0" — adjust for Linux as needed.
  - Status bar expects a Nerd Font for glyphs.
EOF
