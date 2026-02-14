#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="/usr/local"
GO_DIR="$INSTALL_DIR/go"

echo "Определяем архитектуру..."
ARCH=$(uname -m)

case "$ARCH" in
    x86_64) GOARCH="amd64" ;;
    aarch64 | arm64) GOARCH="arm64" ;;
    armv6l) GOARCH="armv6l" ;;
    *) echo "Неподдерживаемая архитектура: $ARCH"; exit 1 ;;
esac

echo "Получаем последнюю стабильную версию..."
LATEST=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
echo "Версия: $LATEST"

TARBALL="${LATEST}.linux-${GOARCH}.tar.gz"
URL="https://go.dev/dl/${TARBALL}"

echo "Скачиваем..."
curl -LO "$URL"

echo "Удаляем старую версию..."
sudo rm -rf "$GO_DIR"

echo "Устанавливаем..."
sudo tar -C "$INSTALL_DIR" -xzf "$TARBALL"
rm "$TARBALL"

# Добавляем PATH в bashrc если нет
if ! grep -q '/usr/local/go/bin' "$HOME/.bashrc"; then
    echo '' >> "$HOME/.bashrc"
    echo '# Go' >> "$HOME/.bashrc"
    echo 'export PATH=$PATH:/usr/local/go/bin' >> "$HOME/.bashrc"
fi

# Активируем в текущей сессии
export PATH=$PATH:/usr/local/go/bin

echo
echo "Проверка:"
if command -v go >/dev/null 2>&1; then
    go version
else
    echo "Ошибка: go не найден в PATH"
fi

