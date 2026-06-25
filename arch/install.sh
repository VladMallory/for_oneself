#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Установка base-devel (нужно для сборки AUR) ==="
sudo pacman -Syu --noconfirm --needed base-devel

log "=== Установка yay (AUR helper) ==="
if ! command -v yay &> /dev/null; then
    sudo pacman -S --noconfirm go
    cd /tmp
    git clone --depth 1 https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm --skippgpcheck
    cd "$DIR"
fi

log "=== Запуск всех скриптов в $DIR ==="
for script in "$DIR"/*.sh; do
    name="$(basename "$script")"
    [[ "$name" == "install.sh" || "$name" == "gen-config.sh" ]] && continue
    log "--- Выполняется: $name ---"
    bash "$script"
    log "--- Готово: $name ---"
done

log "=== Все скрипты выполнены ==="
