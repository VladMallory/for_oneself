# Arch установка
## Одной командой
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/VladMallory/for_oneself/main/arch/install-quck.sh)
Либо через wget, если нет curl:
bash <(wget -qO- https://raw.githubusercontent.com/VladMallory/for_oneself/main/arch/install-quck.sh)
```

## Вручную
```bash
pacman -Sy git
git clone https://github.com/VladMallory/for_oneself.git
cd for_oneself/arch
bash gen-config.sh
archinstall --config archinstall-config.json --creds archinstall-creds.json
```


### Настройка системы (после перезагрузки)
```bash
cd for_oneself/arch
./install.sh
```

Скрипт выполнит:
- обновление системы
- установку yay (AUR)
- Sway + Waybar + Alacritty + всё окружение
- Go, Rust, Docker, lazygit
- Zsh + Oh My Zsh + Powerlevel10k
- AstroNvim (Neovim)
- OpenCode AI
- QEMU/KVM + libvirt + virt-manager
- btop, fastfetch, firefox, thunar и др.

### Что устанавливается

| Скрипт | Назначение |
|--------|-----------|
| `packages/alacritty.sh` | Alacritty + конфиг |
| `packages/wm.sh` | Sway, Waybar, rofi, mako, pipewire, grim, NetworkManager |
| `packages/dev.sh` | Go, Rust, Docker, lazygit, gofumpt, golangci-lint |
| `packages/zsh.sh` | Zsh, Oh My Zsh, Powerlevel10k, плагины |
| `packages/packages.sh` | btop, fastfetch, firefox, thunar, qbittorrent и др. |
| `packages/opencode.sh` | OpenCode CLI |
| `packages/astro-nvim.sh` | Neovim + AstroNvim v3 |
| `packages/virtual-machine.sh` | QEMU/KVM, libvirt, virt-manager |
| `packages/zz-flatpak.sh` | Плагин Flatpak |
