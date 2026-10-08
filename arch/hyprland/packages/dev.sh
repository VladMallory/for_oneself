#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Docker и Compose ==="
sudo pacman -S --needed --noconfirm docker docker-compose docker-buildx

log "=== Make ==="
sudo pacman -S --needed --noconfirm make

log "=== Lazygit ==="
if ! command -v lazygit &> /dev/null; then
    go install -v github.com/jesseduffield/lazygit@latest
fi

log "=== Инструменты Go ==="
command -v gofumpt &> /dev/null || go install -v mvdan.cc/gofumpt@latest
command -v golangci-lint &> /dev/null || go install -v github.com/golangci/golangci-lint/cmd/golangci-lint@latest

log "=== Настройка Docker ==="
sudo systemctl enable --now docker.service
if ! getent group docker | grep -q "\b${USER}\b"; then
    sudo usermod -aG docker "$USER"
    log "Пользователь добавлен в группу docker. Перелогиньтесь или выполните 'newgrp docker'"
fi

log "=== Go в PATH ==="
if ! grep -q "go/bin" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'EOF'

# Go
export PATH=$PATH:$HOME/go/bin
EOF
fi

log "Dev-окружение готово"
