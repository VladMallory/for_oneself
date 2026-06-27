#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Включение en_US.UTF-8 в locale.gen ==="
sudo sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sudo locale-gen

log "Локаль en_US.UTF-8 включена"
