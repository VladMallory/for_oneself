#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Фикс split lock mitigation (зависания от Wine/Proton игр) ==="

CURRENT=$(cat /proc/sys/kernel/split_lock_mitigate 2>/dev/null)
if [[ "$CURRENT" != "0" ]]; then
    echo 0 | sudo tee /proc/sys/kernel/split_lock_mitigate
    log "split_lock_mitigate = 0"
else
    log "split_lock_mitigate уже выключен."
fi

log "Готово!"
