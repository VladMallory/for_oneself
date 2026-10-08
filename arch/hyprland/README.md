# Arch установка (Hyprland + Noctalia)
## Шаг 1 — чистый Arch без конфигов (в live ISO)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/VladMallory/for_oneself/main/arch/hyprland/install-quck-live.sh)
Либо через wget, если нет curl:
bash <(wget -qO- https://raw.githubusercontent.com/VladMallory/for_oneself/main/arch/hyprland/install-quck-live.sh)
```

## Вручную
```bash
pacman -Sy git
git clone https://github.com/VladMallory/for_oneself.git
cd for_oneself/arch/hyprland
bash gen-config.sh
archinstall --config archinstall-config.json --creds archinstall-creds.json
```


# Шаг 2 — конфиги и всё остальное (в установленной системе)
## Автоматический вариант
```bash
curl -fsSL https://raw.githubusercontent.com/vladmallory/for_oneself/main/arch/hyprland/install-quck-post.sh | sudo bash
```

## Ручной вариант
```bash
pacman -Sy git
git clone https://github.com/VladMallory/for_oneself.git
cd for_oneself/arch/hyprland
./install.sh
```
