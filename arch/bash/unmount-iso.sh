#!/bin/bash
devs=$(lsblk -o NAME,TYPE,MOUNTPOINT -l | grep ' loop ' | awk '{print $1}')
[ -z "$devs" ] && notify-send "Unmount ISO" "Нет смонтированных ISO" && exit 0
for d in $devs; do
  udisksctl unmount -b "/dev/$d" 2>/dev/null
  udisksctl loop-delete -b "/dev/$d" 2>/dev/null
done
notify-send "Unmount ISO" "Все ISO отмонтированы"

