#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$DIR")"

echo "=== Бэкап старого Neovim конфига ==="
if [ -d ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.bak.$(date +%s)
fi

echo "=== Установка Neovim и зависимостей ==="
sudo pacman -S --needed --noconfirm neovim ripgrep

echo "=== Клонирование AstroNvim template ==="
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git

echo "=== Копирование конфигурации astronvim v3 ==="
cp -r "$REPO/astronvim/v3/"* ~/.config/nvim/

echo "AstroNvim установлен и настроен"
