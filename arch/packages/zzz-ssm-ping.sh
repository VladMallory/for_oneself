#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Установка ssm (Secure Shell Manager) ==="
if ! command -v ssm >/dev/null 2>&1; then
    yay -S --needed --noconfirm ssm-bin
else
    log "ssm уже установлен, пропускаем"
fi

log "=== Автопинг всех хостов при запуске TUI ==="
if [ -f "$HOME/.zshrc" ] && ! grep -q "SSM_PING" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'EOF'

# ssm: пинговать все хосты при запуске TUI
export SSM_PING=1
EOF
    log "SSM_PING=1 добавлен в ~/.zshrc"
else
    log "SSM_PING уже настроен, пропускаем"
fi

log "ssm готов. Запускайте 'ssm' — пингует все хосты из ~/.ssh/config при старте"
