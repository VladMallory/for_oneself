#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(dirname "$DIR")"

echo "=== Установка Alacritty ==="
sudo pacman -S --needed --noconfirm alacritty

echo "=== Копирование конфига Alacritty ==="
mkdir -p ~/.config/alacritty
cp "$REPO/alacrity/alacritty.toml" ~/.config/alacritty/alacritty.toml

echo "Alacritty установлен и настроен"
