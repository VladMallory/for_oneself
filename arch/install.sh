#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/packages/common.sh"

source ~/.bashrc 2>/dev/null || true

log "=== Установка yay (AUR helper) ==="
if ! command -v yay &> /dev/null; then
    cd /tmp
    rm -rf yay
    git clone --depth 1 https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm --skippgpcheck
    cd "$DIR"
fi

log "=== Запуск всех скриптов в $DIR/packages ==="
for script in "$DIR"/packages/*.sh; do
    name="$(basename "$script")"
    log "--- Выполняется: $name ---"
    bash "$script" 2>&1
    log "--- Готово: $name ---"
done

log "=== Все скрипты выполнены ==="
