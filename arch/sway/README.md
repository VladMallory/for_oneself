# Arch установка (Sway)
## Одной командой
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/VladMallory/for_oneself/main/arch/sway/install-quck-live.sh)
Либо через wget, если нет curl:
bash <(wget -qO- https://raw.githubusercontent.com/VladMallory/for_oneself/main/arch/sway/install-quck-live.sh)
```

## Вручную
```bash
pacman -Sy git
git clone https://github.com/VladMallory/for_oneself.git
cd for_oneself/arch/sway
bash gen-config.sh
archinstall --config archinstall-config.json --creds archinstall-creds.json
```


# После установки
## Автоматический вариант
```bash
curl -fsSL https://raw.githubusercontent.com/vladmallory/for_oneself/main/arch/sway/install-quck-post.sh | sudo bash
```

## Ручной вариант
```bash
cd for_oneself/arch/sway
pacman -Sy git
git clone https://github.com/VladMallory/for_oneself.git
cd for_oneself/arch/sway
./install.sh
```
