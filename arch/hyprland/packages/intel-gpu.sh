#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Intel iGPU: blacklist xe (остаёмся на i915) ==="
echo 'blacklist xe' | sudo tee /etc/modprobe.d/blacklist-xe.conf > /dev/null

log "=== Intel iGPU: i915.enable_guc=2 в GRUB ==="
CHANGED=0
if ! grep -q 'i915.enable_guc=2' /etc/default/grub; then
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\([^"]*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 i915.enable_guc=2"/' /etc/default/grub
    CHANGED=1
fi

if [ "$CHANGED" = 1 ]; then
    sudo grub-mkconfig -o /boot/grub/grub.cfg
else
    log "  i915.enable_guc=2 уже в cmdline, пропускаем grub-mkconfig"
fi

log "Intel iGPU настроен"
