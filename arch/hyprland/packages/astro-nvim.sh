#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$(dirname "$(dirname "$DIR")")")"
source "$DIR/common.sh"

log "=== Проверка AstroNvim ==="
if [ -d ~/.config/nvim/lua/user ]; then
    log "AstroNvim уже настроен, пропускаем"
    exit 0
fi

log "=== Установка Neovim и зависимостей ==="
sudo pacman -S --needed --noconfirm neovim ripgrep

log "=== Установка AstroNvim через astronvim/install.sh ==="
bash "$REPO/astronvim/install.sh"

log "AstroNvim установлен и настроен"
