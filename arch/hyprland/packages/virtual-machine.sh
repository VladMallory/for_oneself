#!/bin/bash

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Установка QEMU/KVM + libvirt + virt-manager ==="
sudo pacman -S --needed --noconfirm \
    qemu-full libvirt virt-manager \
    edk2-ovmf dnsmasq iptables-nft

log "=== Включение libvirtd ==="
sudo systemctl enable --now libvirtd.service

log "=== Добавление пользователя в группы ==="
sudo usermod -aG libvirt,kvm "$USER"

log "Виртуальные машины готовы. Перелогиньтесь или выполните 'newgrp libvirt && newgrp kvm'"
