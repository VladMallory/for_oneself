#!/usr/bin/env bash
set -e

pacman -Sy --noconfirm curl git base-devel go

# SUDO_USER может быть root — берём первого обычного пользователя.
BUILD_USER="${SUDO_USER:-}"
if [ -z "$BUILD_USER" ] || [ "$BUILD_USER" = "root" ]; then
    BUILD_USER="$(logname 2>/dev/null || true)"
fi
if [ -z "$BUILD_USER" ] || [ "$BUILD_USER" = "root" ]; then
    BUILD_USER="$(awk -F: '$3 >= 1000 && $3 < 65534 {print $1; exit}' /etc/passwd)"
fi
if [ -z "$BUILD_USER" ] || [ "$BUILD_USER" = "root" ] || ! id "$BUILD_USER" >/dev/null 2>&1; then
    echo "ОШИБКА: не удалось определить обычного пользователя для установки" >&2
    exit 1
fi

rm -rf /tmp/for_oneself
git clone --depth 1 https://github.com/VladMallory/for_oneself.git /tmp/for_oneself

chown -R "$BUILD_USER" /tmp/for_oneself

cd /tmp/for_oneself/arch/hyprland
sudo -u "$BUILD_USER" -H bash install.sh < /dev/tty
