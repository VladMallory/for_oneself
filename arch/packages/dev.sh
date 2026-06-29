#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Rust (rustup через зеркало Tsinghua) ==="
if ! command -v cargo &> /dev/null; then
    export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
    export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

log "=== Кэш для cargo ==="
mkdir -p ~/.cargo
cat >> ~/.cargo/config.toml << 'EOF'

[source.crates-io]
replace-with = "tuna"

[source.tuna]
registry = "sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/"
EOF

log "=== Docker и Compose ==="
sudo pacman -S --needed --noconfirm docker docker-compose

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
