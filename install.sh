#!/usr/bin/env bash
# Install city-blue.
#
# Default (safe / package-manager friendly):
#   - symlink tmux.conf, conf.d, scripts, themes into $HOME/.tmux
#   - clone tpm if missing
#   - run build.sh
#   - print caveats for everything else (no edits to ~/.zshrc, ~/.config, etc.)
#
# Opt-in flags (legacy "do everything for me" behaviour = --full):
#   --with-zsh        inject per-project tmux() wrapper into ~/.zshrc
#   --with-ghostty    overwrite ~/.config/ghostty/config
#   --with-fonts      brew install JetBrainsMono Nerd Font + Sarabun
#   --with-bash       brew install bash 4+ if missing
#   --with-gitignore  add resurrect pattern to global gitignore
#   --full            all of the above
#   --minimal         alias for the default (explicit)
#   -h, --help        show this help
#
# Existing real files/dirs are backed up with a timestamp suffix.
# Existing symlinks are replaced silently.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

WITH_ZSH=0
WITH_GHOSTTY=0
WITH_FONTS=0
WITH_BASH=0
WITH_GITIGNORE=0

usage() { sed -n '2,20p' "$0"; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-zsh)       WITH_ZSH=1 ;;
    --with-ghostty)   WITH_GHOSTTY=1 ;;
    --with-fonts)     WITH_FONTS=1 ;;
    --with-bash)      WITH_BASH=1 ;;
    --with-gitignore) WITH_GITIGNORE=1 ;;
    --full)
      WITH_ZSH=1; WITH_GHOSTTY=1; WITH_FONTS=1; WITH_BASH=1; WITH_GITIGNORE=1 ;;
    --minimal) ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'unknown flag: %s\n' "$1" >&2; usage; exit 2 ;;
  esac
  shift
done

log()    { printf '\033[1;36m[install]\033[0m %s\n' "$*"; }
warn()   { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
caveat() { printf '\033[1;35m[caveat]\033[0m %s\n' "$*"; }

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

# ── Core install (always runs) ────────────────────────────────────────────
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

log "generating themes/city-blue.conf via build.sh"
bash "$REPO_DIR/build.sh"

# ── Opt-in side effects ───────────────────────────────────────────────────

ensure_bash4() {
  local bash_major=${BASH_VERSINFO[0]:-0}
  if (( bash_major >= 4 )); then
    log "bash ${BASH_VERSION} ok"
    return
  fi
  if [[ "$(uname)" != "Darwin" ]] || ! command -v brew >/dev/null 2>&1; then
    warn "bash ${BASH_VERSION} < 4 and brew unavailable — install bash 4+ manually"
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

ensure_global_gitignore() {
  local ignore_file="${XDG_CONFIG_HOME:-$HOME/.config}/git/ignore"
  local pattern='${RESURRECT_DIR*'
  mkdir -p "$(dirname "$ignore_file")"
  touch "$ignore_file"
  if grep -qxF "$pattern" "$ignore_file"; then
    log "global gitignore already has resurrect pattern"
  else
    printf '%s\n' "$pattern" >> "$ignore_file"
    log "added resurrect pattern to $ignore_file"
  fi
}

setup_zsh_tmux() {
  if ! command -v zsh >/dev/null 2>&1; then
    warn "zsh not found — skipping ~/.zshrc tmux helper"
    return
  fi
  local rc="$HOME/.zshrc"
  local begin='# >>> city-blue per-project tmux >>>'
  local end='# <<< city-blue per-project tmux <<<'
  local src_line="source \"$REPO_DIR/share/city-blue.zsh\""
  if [[ -f "$rc" ]] && grep -qF "$begin" "$rc"; then
    log "zsh tmux helper already present in $rc"
    return
  fi
  [[ -f "$rc" ]] || touch "$rc"
  cp "$rc" "${rc}.bak-${STAMP}"
  {
    printf '\n%s\n' "$begin"
    printf '%s\n' "$src_line"
    printf '%s\n' "$end"
  } >> "$rc"
  log "added tmux helper to $rc (backup: ${rc}.bak-${STAMP})"
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

(( WITH_BASH ))      && ensure_bash4
(( WITH_FONTS ))     && install_fonts
(( WITH_GITIGNORE )) && ensure_global_gitignore
(( WITH_ZSH ))       && setup_zsh_tmux
(( WITH_GHOSTTY ))   && setup_ghostty

# ── Caveats for things we did NOT do ──────────────────────────────────────

(( WITH_ZSH )) || caveat "per-project tmux wrapper not installed.
    To enable: add this line to your ~/.zshrc
      source \"$REPO_DIR/share/city-blue.zsh\"
    Or re-run: bash install.sh --with-zsh"

(( WITH_GHOSTTY )) || caveat "Ghostty config not modified.
    Recommended settings: see $REPO_DIR/share/ghostty.example.conf
    Or re-run: bash install.sh --with-ghostty"

(( WITH_FONTS )) || caveat "fonts not installed. Install a Nerd Font for glyphs:
      brew install --cask font-jetbrains-mono-nerd-font font-sarabun
    Or re-run: bash install.sh --with-fonts"

if (( ! WITH_BASH )) && (( ${BASH_VERSINFO[0]:-0} < 4 )); then
  caveat "bash ${BASH_VERSION} detected. Widgets need bash 4+:
      brew install bash
    Or re-run: bash install.sh --with-bash"
fi

cat <<EOF

[install] done.

Next steps:
  1. Start or attach tmux:        tmux new -s main
  2. Reload config:               tmux source ~/.tmux.conf
  3. Install plugins (TPM):       press prefix + I  (default prefix: C-b)

Notes:
  - Re-run \`bash build.sh\` after editing the palette or layout in build.sh.
  - Status bar expects a Nerd Font for glyphs.
  - For full setup including shell wrapper, fonts, Ghostty:
      bash install.sh --full
EOF
