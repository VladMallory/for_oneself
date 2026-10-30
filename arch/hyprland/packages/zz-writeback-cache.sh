#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Ограничение writeback-кеша (макс. 32 МБ несохранённых данных) ==="

CONF=/etc/sysctl.d/90-writeback-cache.conf

sudo tee "$CONF" > /dev/null <<'EOF'
# Максимум данных, которые могут висеть в RAM и ещё не быть на диске.
# Без этого ядро держит до vm.dirty_ratio (20%) от всей RAM, из-за чего
# прогресс копирования показывает "готово" задолго до записи на устройство.
vm.dirty_background_bytes = 8388608
vm.dirty_bytes = 33554432
vm.dirty_expire_centisecs = 300
vm.dirty_writeback_centisecs = 100
EOF

sudo sysctl -q --system

log "Применено:"
printf '  %-26s = %s\n' \
    dirty_background_bytes "$(cat /proc/sys/vm/dirty_background_bytes)" \
    dirty_bytes "$(cat /proc/sys/vm/dirty_bytes)" \
    dirty_expire_centisecs "$(cat /proc/sys/vm/dirty_expire_centisecs)" \
    dirty_writeback_centisecs "$(cat /proc/sys/vm/dirty_writeback_centisecs)"

if [[ "$(cat /proc/sys/vm/dirty_bytes)" != "33554432" ]]; then
    log "ВНИМАНИЕ: значение не применилось — проверь /etc/sysctl.conf и /run/sysctl.d"
    exit 1
fi

log "Готово! Макс. несохранённых данных: 32 МБ"
