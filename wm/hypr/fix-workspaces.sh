#!/bin/sh
# Раскладываем окна по воркспейсам после старта.
# Brave стартует дольше всех, поэтому повторы с паузой, а не один выстрел.
sleep 3
# Сначала Telegram (быстрый), затем с паузой Brave (медленный) — как ты и просил
hyprctl dispatch movetoworkspace '5,class:^(org.telegram.desktop)$' >/dev/null 2>&1
sleep 1
hyprctl dispatch movetoworkspace '4,class:^(brave-browser)$' >/dev/null 2>&1
# Контрольные повторы: вдруг окно появилось позже
for i in 1 2 3 4 5 6; do
  sleep 2
  hyprctl dispatch movetoworkspace '4,class:^(brave-browser)$' >/dev/null 2>&1
  hyprctl dispatch movetoworkspace '5,class:^(org.telegram.desktop)$' >/dev/null 2>&1
done
