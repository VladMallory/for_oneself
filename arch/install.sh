#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Установка base-devel (нужно для сборки AUR) ==="
sudo pacman -Syu --noconfirm --needed base-devel

echo "=== Установка yay (AUR helper) ==="
if ! command -v yay &> /dev/null; then
    sudo pacman -S --noconfirm go
    cd /tmp
    git clone --depth 1 https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm --skippgpcheck
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
