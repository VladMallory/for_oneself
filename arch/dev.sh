#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$DIR")"

echo "=== Go ==="
sudo pacman -S --needed --noconfirm go

echo "=== Rust (rustup через зеркало Tsinghua) ==="
if ! command -v rustup &> /dev/null; then
    export RUSTUP_DIST_SERVER=https://mirrors.tuna.tsinghua.edu.cn/rustup
    export RUSTUP_UPDATE_ROOT=https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

echo "=== Кэш для cargo ==="
mkdir -p ~/.cargo
cat >> ~/.cargo/config.toml << 'EOF'

[source.crates-io]
replace-with = "tuna"

[source.tuna]
registry = "sparse+https://mirrors.tuna.tsinghua.edu.cn/crates.io-index/"
EOF

echo "=== Docker и Compose ==="
sudo pacman -S --needed --noconfirm docker docker-compose

echo "=== Make ==="
sudo pacman -S --needed --noconfirm make

echo "=== Lazygit ==="
go install -v github.com/jesseduffield/lazygit@latest

echo "=== Инструменты Go ==="
go install -v mvdan.cc/gofumpt@latest
go install -v github.com/golangci/golangci-lint/cmd/golangci-lint@latest

echo "=== Настройка Docker ==="
sudo systemctl enable --now docker.service
if ! getent group docker | grep -q "\b${USER}\b"; then
    sudo usermod -aG docker "$USER"
    echo "Пользователь добавлен в группу docker. Перелогиньтесь или выполните 'newgrp docker'"
fi

echo "=== Go в PATH ==="
if ! grep -q "go/bin" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << 'EOF'

# Go
export PATH=$PATH:$HOME/go/bin
EOF
fi

echo "Dev-окружение готово"
