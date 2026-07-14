#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Фикс rust-analyzer: установка rust-src ==="

if rustup component list --installed 2>/dev/null | grep -q "^rust-src$"; then
    log "  rust-src уже установлен."
    exit 0
fi

log "  rust-src не найден. Временное переключение на официальный сервер..."
RUSTUP_DIST_SERVER=https://static.rust-lang.org rustup component add rust-src

if rustup component list --installed 2>/dev/null | grep -q "^rust-src$"; then
    log "  rust-src успешно установлен."
    log "  Перезапусти rust-analyzer в Neovim: :LspRestart rust_analyzer"
else
    log "  ОШИБКА: не удалось установить rust-src."
    exit 1
fi
