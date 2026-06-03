#!/usr/bin/env bash
# Sync tpm plugins: install missing, update all, clean unused.
set -e

TPM_BIN="${HOME}/.tmux/plugins/tpm/bin"

if [ ! -d "${TPM_BIN}" ]; then
  tmux display-message "tpm not installed"
  exit 1
fi

"${TPM_BIN}/install_plugins"
"${TPM_BIN}/update_plugins" all
"${TPM_BIN}/clean_plugins"

tmux display-message "plugins synced"
