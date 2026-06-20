#!/bin/bash

# Сбой при любой ошибке
set -e

echo "=== 1. Обновление системы и установка базовых пакетов ==="
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm \
    alacritty btop curl fastfetch ffmpeg git make pkg-config \
    rsync stow tree neovim lazygit vim wget zsh p7zip flatpak \
    sway waybar rofi polybar mako grim slurp \
    pipewire wireplumber pavucontrol brightnessctl \
    networkmanager NetworkManager-applet blueman xorg-xwayland

# Установка шрифта JetBrainsMono (необходим для Waybar)
sudo pacman -S --needed --noconfirm ttf-jetbrains-mono-nerd

echo "=== 2. Установка AUR помощника (yay) ==="
if ! command -v yay &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
    cd ~
fi

echo "=== 3. Установка специфичных пакетов из AUR ==="
yay -S --needed --noconfirm localsend-bin flclash-bin lazydocker-bin grimshot

echo "=== 4. Настройка Go, Docker и инструментов разработчика ==="
sudo pacman -S --needed --noconfirm go docker docker-compose golangci-lint

# Форматировщик gofumpt
go install mvdan.cc/gofumpt@latest

# Установка open-code через официальный скрипт
echo "Установка open-code..."
curl -fsSL https://opencode.ai/install | bash

# Настройка прав для Docker
sudo systemctl enable --now docker.service
if ! getent group docker | grep -q "\b${USER}\b"; then
    sudo usermod -aG docker $USER
fi

echo "=== 5. Установка Oh My Zsh и плагинов ==="
# Установка Oh My Zsh (если еще не установлен)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Создание папки для кастомных плагинов
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/plugins"

# Скачивание ваших плагинов, если их нет
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

echo "=== 6. Развертывание конфигурационных файлов (Zsh, Sway, Waybar) ==="
mkdir -p ~/.config/sway
mkdir -p ~/.config/waybar

# --- ЗАПИСЬ .zshrc ---
cat << 'EOF' > ~/.zshrc
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Plugins
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh

# User configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# opencode
export PATH=/home/pc/.opencode/bin:$PATH
export PATH=$PATH:$HOME/go/bin

# Environment & Cargo
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
export DISPLAY=:0

# Алиасы
alias wails-dev="PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig wails dev -tags webkit2_41"
alias temp='sensors coretemp-isa-0000'
alias n='nvim'
alias n1='cd ~/golang/proxyMaster_v2/ && n'
alias o1='cd ~/golang/proxyMaster_v2/ && opencode'
alias o='opencode'

# Обновление системы под Arch Linux (замена apt на pacman/yay)
alias update='sudo pacman -Syu --noconfirm && yay -Sua --noconfirm'

doc() {
  ids=$(docker ps -q)
  [ -n "$ids" ] && docker stop $ids
}

# npm
export PATH="$HOME/.npm-global/bin:$PATH"
EOF


# --- ЗАПИСЬ CONFiG SWAY ---
cat << 'EOF' > ~/.config/sway/config
### variables
set $mod Mod1
set $term alacritty
set $menu rofi -show drun -show-icons -modi drun,run,window,favorites:~/.config/rofi/favorites.sh

exec_always dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway

### environment
exec_always dbus-update-activation-environment --systemd GTK_THEME=Yaru-dark
exec_always dbus-update-activation-environment --systemd MOZ_ENABLE_WAYLAND=1
exec_always dbus-update-activation-environment --systemd QT_QPA_PLATFORM=wayland
exec_always dbus-update-activation-environment --systemd SDL_VIDEODRIVER=wayland

### keyboard layout
input * {
    xkb_layout us,ru
    xkb_options grp:alt_space_toggle
}

input type:touchpad {
    natural_scroll enabled
    tap enabled
}

bindsym --to-code $mod+f layout toggle tabbed split

### Скриншоты
bindsym Print exec grimshot copy area
bindsym Shift+Print exec grimshot copy screen
bindsym Ctrl+Print exec grimshot copy active

### terminal
bindsym $mod+Return exec $term

### launcher
bindsym --to-code $mod+d exec $menu

### close window
bindsym --to-code $mod+q kill

### reload config
bindsym $mod+Shift+c reload

### exit sway
bindsym $mod+Shift+e exec "swaymsg exit"

### focus movement
bindsym --to-code $mod+h focus left
bindsym --to-code $mod+j focus down
bindsym --to-code $mod+k focus up
bindsym --to-code $mod+l focus right

### move windows
bindsym --to-code $mod+Shift+h move left
bindsym --to-code $mod+Shift+j move down
bindsym --to-code $mod+Shift+k move up
bindsym --to-code $mod+Shift+l move right

### workspaces
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5
bindsym $mod+6 workspace 6

bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4
bindsym $mod+Shift+5 move container to workspace 5
bindsym $mod+Shift+6 move container to workspace 6

### volume
bindsym --to-code $mod+p exec pavucontrol
bindsym XF86AudioRaiseVolume exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

### brightness
bindsym XF86MonBrightnessUp exec brightnessctl set +10%
bindsym XF86MonBrightnessDown exec brightnessctl set 10%-

### autostart
exec_always waybar
exec_always /usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1
exec_always nm-applet --no-agent
exec_always mako
exec_always xembedsniproxy
exec_always blueman-applet

### background
output * bg "/home/pc/Изображения/Город.jpg" fill

for_window [class="xembedsniproxy"] floating enable
for_window [class="xembedsniproxy"] move position -200 -200

for_window [class="Polybar"] floating enable
for_window [class="Polybar"] sticky enable
for_window [class="Polybar"] border none
for_window [class="Polybar"] move position 0 0
for_window [class="Polybar"] inhibit_idle fullscreen

# Colors
client.focused          #3c3836 #3c3836 #a89984 #3c3836 #3c3836
client.focused_inactive #3c3836 #3c3836 #a89984 #3c3836 #3c3836
client.unfocused        #282828 #282828 #928374 #282828 #282828
client.urgent           #cc241d #cc241d #fbf1c7 #cc241d #cc241d
client.placeholder      #282828 #282828 #928374 #282828 #282828

# Autostart apps
exec_always swaymsg "workspace 2; exec flatpak run com.brave.Browser"

# Hotkeys
bindsym --to-code $mod+t exec flatpak run org.telegram.desktop
bindsym --to-code $mod+b exec flatpak run com.brave.Browser
EOF


# --- ЗАПИСЬ CONFIG WAYBAR ---
cat << 'EOF' > ~/.config/waybar/config
{
  "layer": "top",
  "position": "top",
  "height": 28,

  "modules-left": ["sway/workspaces"],
  "modules-center": ["clock"],
  "modules-right": ["tray", "sway/language", "pulseaudio", "backlight", "battery"],

  "pulseaudio": {
    "format": "VOL {volume}%"
  },

  "backlight": {
    "format": "BR {percent}%"
  },

  "network": {
    "format-wifi": "",
    "format-disconnected": "󰤭"
  },

  "battery": {
    "format": "BAT {capacity}%"
  },

  "clock": {
    "format": "{:%H:%M}"
  },

  "sway/language": {
    "format": "{short}",
    "tooltip": false
  },

  "tray": {
    "icon-size": 16,
    "spacing": 8
  }
}
EOF


# --- ЗАПИСЬ STYLE WAYBAR ---
cat << 'EOF' > ~/.config/waybar/style.css
* {
  font-family: "JetBrainsMono Nerd Font";
  font-size: 13px;
}

window#waybar {
  background: #282828;
  color: #ebdbb2;
}

#workspaces button {
  padding: 0 8px;
  color: #a89984;
  background: transparent;
}

#workspaces button.focused {
  color: #fabd2f;
  border-bottom: 2px solid #d65d0e;
}

#clock {
  color: #ebdbb2;
}

#battery {
  color: #b8bb26;
}

#network {
  color: #83a598;
}

#pulseaudio {
  color: #fabd2f;
}

#backlight {
  color: #fe8019;
}

#clock,
#battery,
#network,
#pulseaudio,
#backlight {
  margin-left: 10px;
  margin-right: 10px;
}
EOF

echo "=== 7. Смена дефолтной оболочки на ZSH ==?"
if [ "$SHELL" != "/usr/bin/zsh" ]; then
    sudo chsh -s /usr/bin/zsh $USER
fi

echo "Все системные пакеты, Go, Docker, OpenCode и Zsh установлены и настроены! ==="
