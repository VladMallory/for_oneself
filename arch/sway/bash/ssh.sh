#!/bin/bash

# Интерактивный ввод данных
read -p "Введите IP сервера: " IP
read -p "Введите имя сервера (alias): " ALIAS
read -p "Введите пользователя (нажми Enter для root): " USER
read -p "Введите порт (нажми Enter для 22): " PORT
read -p "Введите пароль от сервера: " PASS
echo "" # Перенос строки после скрытого ввода пароля

# Проверка, что обязательные поля заполнены
if [ -z "$IP" ] || [ -z "$ALIAS" ] || [ -z "$PASS" ]; then
    echo "❌ Ошибка: IP, имя сервера и пароль обязательны!"
    exit 1
fi

# Значения по умолчанию для порта и юзера
PORT=${PORT:-22}
USER=${USER:-root}

KEY_PATH="$HOME/.ssh/id_ed25519_$ALIAS"

echo "======================================"
echo "⚙️ Настройка сервера: $ALIAS ($USER@$IP:$PORT)"
echo "======================================"

# 1. Генерируем ключ
echo "[1/3] Генерация SSH-ключа..."
ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "$ALIAS" -q

# 2. Копируем ключ на сервер
echo "[2/3] Отправка ключа на сервер..."
sshpass -p "$PASS" ssh-copy-id -o StrictHostKeyChecking=no -p "$PORT" -i "$KEY_PATH.pub" "$USER@$IP"

# Проверка успешности подключения
if [ $? -ne 0 ]; then
    echo "❌ Ошибка при отправке ключа! Проверь пароль, IP или доступность порта."
    # Удаляем созданный ключ, если произошла ошибка
    rm -f "$KEY_PATH" "$KEY_PATH.pub"
    exit 1
fi

# 3. Добавляем запись в config
echo "[3/3] Запись в ~/.ssh/config..."
cat <<EOF >> "$HOME/.ssh/config"

Host $ALIAS
    HostName $IP
    User $USER
    Port $PORT
    IdentityFile $KEY_PATH
EOF

echo "✅ Готово! Теперь можно подключаться: ssh $ALIAS"
