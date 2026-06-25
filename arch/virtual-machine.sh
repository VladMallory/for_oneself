#!/bin/bash

set -e

echo "=== Установка QEMU/KVM + libvirt + virt-manager ==="
sudo pacman -S --needed --noconfirm \
    qemu-full libvirt virt-manager \
    edk2-ovmf dnsmasq iptables-nft

echo "=== Включение libvirtd ==="
sudo systemctl enable --now libvirtd.service

echo "=== Добавление пользователя в группы ==="
sudo usermod -aG libvirt,kvm "$USER"

echo "Виртуальные машины готовы. Перелогиньтесь или выполните 'newgrp libvirt && newgrp kvm'"
