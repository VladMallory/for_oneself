#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Включение en_US.UTF-8 и ru_RU.UTF-8 в locale.gen ==="
sudo sed -i \
  -e 's/^#en_US.UTF-8/en_US.UTF-8/' \
  -e 's/^#ru_RU.UTF-8/ru_RU.UTF-8/' \
  /etc/locale.gen
sudo locale-gen

log "Локали en_US.UTF-8 и ru_RU.UTF-8 включены"
