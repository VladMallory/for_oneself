#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/packages/common.sh"

source ~/.bashrc 2>/dev/null || true

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

log "=== Запуск всех скриптов в $DIR/packages ==="
for script in "$DIR"/packages/*.sh; do
    name="$(basename "$script")"
    log "--- Выполняется: $name ---"

    tmpfile=$(mktemp)
    bash "$script" 2>&1 | tee "$tmpfile"
    clear

    orange=$'\033[38;5;214m'
    grep -a -F "$orange" "$tmpfile" 2>/dev/null || true
    rm -f "$tmpfile"

    log "--- Готово: $name ---"
done

log "=== Все скрипты выполнены ==="
