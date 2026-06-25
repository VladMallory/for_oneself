#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$DIR")"
source "$DIR/common.sh"

log "=== Проверка AstroNvim ==="
if [ -d ~/.config/nvim/lua/user ]; then
    log "AstroNvim уже настроен, пропускаем"
    exit 0
fi
if [ -d ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
fi

log "=== Установка Neovim и зависимостей ==="
sudo pacman -S --needed --noconfirm neovim ripgrep

log "=== Клонирование AstroNvim template ==="
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git

log "=== Копирование конфигурации astronvim v3 ==="
cp -r "$REPO/astronvim/v3/"* ~/.config/nvim/

log "AstroNvim установлен и настроен"
