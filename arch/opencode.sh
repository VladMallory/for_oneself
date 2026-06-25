#!/bin/bash

set -e

# shellcheck disable=SC1090,SC1091
[ -f ~/.bashrc ] && source ~/.bashrc
[ -f ~/.zshrc ]  && source ~/.zshrc

if command -v opencode &> /dev/null; then
    echo "=== opencode уже установлен, пропускаем ==="
    exit 0
fi

echo "=== Установка opencode ==="
curl -fsSL https://opencode.ai/install | bash

echo "opencode установлен"
