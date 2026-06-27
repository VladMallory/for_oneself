#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

if [ -f "$HOME/.opencode/bin/opencode" ]; then
    log "=== opencode уже установлен, пропускаем ==="
    exit 0
fi

log "=== Установка opencode ==="
curl -fsSL https://opencode.ai/install | bash

log "opencode установлен"
