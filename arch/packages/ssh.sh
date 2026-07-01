#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== SSH config для GitHub ==="

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ ! -f "$HOME/.ssh/config" ] || ! grep -q "github.com" "$HOME/.ssh/config" 2>/dev/null; then
    cat >> "$HOME/.ssh/config" << 'CONFIG'

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github
  IdentitiesOnly yes
CONFIG
    chmod 600 "$HOME/.ssh/config"
    log "GitHub host добавлен в ~/.ssh/config"
else
    log "GitHub host уже есть в ~/.ssh/config"
fi

log "=== Включение systemd SSH-agent socket ==="
systemctl --user enable --now ssh-agent.socket
pkill -u "$USER" -x "ssh-agent" 2>/dev/null || true
export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
ssh-add "$HOME/.ssh/github" 2>/dev/null || true
