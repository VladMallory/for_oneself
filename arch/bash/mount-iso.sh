#!/bin/bash
iso=$(readlink -f "$1")
dev=$(udisksctl loop-setup -f "$iso" 2>&1 | grep -oP "/dev/loop\d+")
[ -z "$dev" ] && notify-send "Mount ISO" "Ошибка: не удалось создать loop-устройство" && exit 1
mountpoint=$(udisksctl mount -b "$dev" 2>&1 | grep -oP "at \K/.+")
[ -z "$mountpoint" ] && notify-send "Mount ISO" "Ошибка: не удалось смонтировать" && exit 1
notify-send "Mount ISO" "Смонтировано: $mountpoint"
thunar "$mountpoint" &

