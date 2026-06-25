#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Обновление системы ==="
sudo pacman -Syu --noconfirm

echo "=== Установка yay (AUR helper) ==="
if ! command -v yay &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd "$DIR"
fi

echo "=== Запуск всех скриптов в $DIR ==="
for script in "$DIR"/*.sh; do
    name="$(basename "$script")"
    [[ "$name" == "install.sh" || "$name" == "gen-config.sh" ]] && continue
    echo "--- Выполняется: $name ---"
    bash "$script"
    echo "--- Готово: $name ---"
done

echo "=== Все скрипты выполнены ==="
