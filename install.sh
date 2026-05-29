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

ensure_bash4() {
  # Widget palette uses associative arrays — bash 3.2 (Apple default) silently
  # collapses every THEME[key] read to a single value, repainting the status
  # bar one solid color. brew install bash brings 5.x onto PATH.
  local bash_major=${BASH_VERSINFO[0]:-0}
  if (( bash_major >= 4 )); then
    log "bash ${BASH_VERSION} ok"
    return
  fi
  if [[ "$(uname)" != "Darwin" ]] || ! command -v brew >/dev/null 2>&1; then
    warn "bash ${BASH_VERSION} is < 4 and brew unavailable — install bash 4+ manually"
    return
  fi
  if brew list bash >/dev/null 2>&1; then
    log "bash 4+ already brewed (ensure /opt/homebrew/bin is ahead of /bin in PATH)"
  else
    log "installing bash (brew)"
    brew install bash
  fi
}

install_fonts() {
  if [[ "$(uname)" != "Darwin" ]]; then
    warn "font install skipped — macOS-only (uses brew cask)"
    return
  fi
  if ! command -v brew >/dev/null 2>&1; then
    warn "font install skipped — brew not found in PATH"
    return
  fi
  for cask in font-jetbrains-mono-nerd-font font-sarabun; do
    if brew list --cask "$cask" >/dev/null 2>&1; then
      log "$cask already installed"
    else
      log "installing $cask"
      brew install --cask "$cask"
    fi
  done
}

setup_ghostty() {
  local cfg_dir="$HOME/.config/ghostty"
  local cfg="$cfg_dir/config"
  mkdir -p "$cfg_dir"
  backup_if_real "$cfg"
  cat > "$cfg" <<'CFG'
font-family = "JetBrainsMono Nerd Font"
font-family = "Sarabun"
font-size = 14
font-feature = +liga
font-feature = +calt
CFG
  log "wrote ghostty config -> $cfg"
}

ensure_bash4
install_fonts
setup_ghostty

log "generating themes/city-blue.conf via build.sh"
bash "$REPO_DIR/build.sh"

cat <<'EOF'

[install] done.

Next steps:
  1. Start or attach tmux:        tmux new -s main
  2. Reload config:               tmux source ~/.tmux.conf
  3. Install plugins (TPM):       press prefix + I  (default prefix: C-b)
  4. Restart Ghostty so it picks up the new font config.

Notes:
  - Re-run `bash build.sh` after editing the palette or layout in build.sh.
  - Tested on macOS. Some scripts use pbcopy / osascript / battery name
    "InternalBattery-0" — adjust for Linux as needed.
  - Status bar expects a Nerd Font for glyphs.
EOF
