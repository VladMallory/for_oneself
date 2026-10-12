#!/bin/bash
# Logitech MX Master 3S: кнопка "Вперед" -> клик колесика (средняя кнопка).
# Всё в одном файле: установка logiops, конфиг, ожидание мыши при старте.
# Стартует из arch/hyprland/install.sh вместе со всеми packages/*.sh.

set -e

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Установка logiops (драйвер Logitech MX Master) ==="
yay -S --needed --noconfirm logiops

log "=== Деплой /etc/logid.cfg (Вперед -> средняя кнопка) ==="
sudo tee /etc/logid.cfg > /dev/null <<'EOF'
// LogiOps config: Logitech MX Master 3S
// Кнопка "Вперед" (cid 0x56) -> клик колесика (средняя кнопка BTN_MIDDLE)
// Клик самого колесика продолжает работать как раньше - теперь оба дают middle-click.
devices: (
{
    name: "MX Master 3S";
    buttons: (
        {
            cid: 0x56;
            action = {
                type: "Keypress";
                keys: ["BTN_MIDDLE"];
            };
        }
    );
}
);
EOF

log "=== Ожидание мыши при старте (до 15 проверок + 5 штатных = ~20) ==="
log "logid по Bluetooth иногда стартует раньше готовности HID++ и сдаётся,"
log "поэтому перед ним ждёт скрипт (спит между проверками, 0% CPU, висит 0 сек постоянно)."
sudo tee /usr/local/bin/logid-wait-bt.sh > /dev/null <<'EOF'
#!/bin/sh
# Ждём готовности Logitech-мыши по Bluetooth перед стартом logid.
# Проверок: до 15 (раз в 2 сек) + затем штатные 5 попыток самого logid = ~20 суммарно.
# Между проверками спим (0% CPU). В конце всегда выходим с 0, чтобы не ронять сервис.
i=0
while [ "$i" -lt 15 ]; do
  for h in /dev/hidraw*; do
    [ -e "$h" ] || continue
    name=$(udevadm info --query=property --name="$h" 2>/dev/null | sed -n 's/^HID_NAME=//p')
    case "$name" in
      Logitech*)
        drv=$(basename "$(readlink "/sys/class/hidraw/$(basename "$h")/device/driver" 2>/dev/null)" 2>/dev/null)
        case "$drv" in
          logitech-hidpp-device|logitech-djreceiver)
            sleep 2
            exit 0
            ;;
        esac
        ;;
    esac
  done
  i=$((i + 1))
  sleep 2
done
exit 0
EOF
sudo chmod +x /usr/local/bin/logid-wait-bt.sh
sudo mkdir -p /etc/systemd/system/logid.service.d
sudo tee /etc/systemd/system/logid.service.d/wait-bt.conf > /dev/null <<'EOF'
[Unit]
After=bluetooth.service

[Service]
ExecStartPre=/usr/local/bin/logid-wait-bt.sh
EOF
sudo systemctl daemon-reload

log "=== Включение logid.service ==="
sudo systemctl enable --now logid.service
sudo systemctl restart logid.service
sleep 2
sudo journalctl -u logid --no-pager -n 20 | grep "Device found" \
    || log "ВНИМАНИЕ: мышь не найдена (выключена?). Включи и перезапусти: sudo systemctl restart logid"

log "logiops готов (кнопка Вперед -> средняя кнопка)"
