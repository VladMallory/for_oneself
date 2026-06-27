#!/bin/bash

DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/common.sh"

log "=== Настройка автосброса faillock каждый час ==="

SERVICE_NAME="faillock-reset"

sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<'EOF'
[Unit]
Description=Reset faillock lockout counters

[Service]
Type=oneshot
ExecStart=/usr/bin/faillock --reset
EOF

sudo tee /etc/systemd/system/${SERVICE_NAME}.timer > /dev/null <<'EOF'
[Unit]
Description=Reset faillock every hour

[Timer]
OnCalendar=hourly
Persistent=true

[Install]
WantedBy=timers.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now ${SERVICE_NAME}.timer

log "=== Таймер faillock-reset запущен ==="
