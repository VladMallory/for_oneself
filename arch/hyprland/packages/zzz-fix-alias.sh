#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

P10K_FILE="$HOME/.p10k.zsh"

log "=== Фикс алиасов: восстановление опций в ~/.p10k.zsh ==="

if [ ! -f "$P10K_FILE" ]; then
    log "  $P10K_FILE не найден, пропускаем"
    exit 0
fi

if grep -q "Restore options" "$P10K_FILE" 2>/dev/null; then
    log "  Блок восстановления уже добавлен, пропускаем"
    exit 0
fi

cat >> "$P10K_FILE" << 'EOF'

# Restore options.
(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
EOF
log "  Блок восстановления опций добавлен в конец $P10K_FILE"
log "  Перезапусти терминал (или source ~/.zshrc), чтобы алиасы заработали"
