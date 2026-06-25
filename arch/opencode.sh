#!/bin/bash

set -e

if [ -f "$HOME/.opencode/bin/opencode" ]; then
    echo "=== opencode уже установлен, пропускаем ==="
    exit 0
fi

echo "=== Установка opencode ==="
curl -fsSL https://opencode.ai/install | bash

echo "opencode установлен"
