-- Конфиг Hyprland 0.57 (Lua).
-- Перенесён из hyprland.conf (формат 0.56). Старый файл оставлен как hyprland.conf.legacy-0.56.

------------------
---- MONITORS ----
------------------

-- HDMI основной 1440p, eDP дублирует его 1в1 на 0x0
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1440@74.96",
    position = "0x0",
    scale    = 1,
})

hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "0x0",
    scale    = 1,
    mirror   = "HDMI-A-1",
})


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia")
    hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")
    hl.exec_cmd("sleep 5; exec happ") -- ждём трей Noctalia, иначе иконки в панели нет
    hl.exec_cmd("brave")
    hl.exec_cmd("Telegram")
    hl.exec_cmd("/home/pc/.config/hypr/fix-workspaces.sh")
    hl.exec_cmd("hypridle") -- автосон через 10 мин простоя (см. hypridle.conf)
end)


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    animations = {
        enabled = true,
    },

    decoration = {
        rounding = 0,
        blur = {
            enabled = false,
        },
        shadow = {
            enabled = false,
        },
    },

    general = {
        gaps_in     = 6,
        gaps_out    = 12,
        border_size = 2,
        -- аналог client.focused / client.unfocused из sway (gruvbox)
        col = {
            active_border   = "rgba(3c3836ff)",
            inactive_border = "rgba(282828ff)",
        },
        layout = "dwindle",
    },

    dwindle = {
        -- dwindle:pseudotile удалён в 0.56 — псевдотайлинг теперь per-window:
        --   bind = $mod,P,pseudo  (.dispatcher: pseudo)
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo   = true,
        disable_splash_rendering = true,
    },

    -- misc:vfr переехал в debug:vfr
    debug = {
        vfr = true,
    },
})

-- animations: windows, 1, 3, default
hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "default" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 6, bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "default", style = "slide" })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "us,ru",
        kb_options = "grp:alt_space_toggle",

        accel_profile = "flat",
        sensitivity   = 0.5,

        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
            scroll_factor  = 0.8,
        },
    },
})

-- MX Master 3S (bluetooth) — ускорение колесика, тачпад не трогаем
hl.device({
    name          = "logitech-mx-master-3s",
    scroll_factor = 1.5,
})


-------------------------------
---- WINDOWS AND WORKSPACES ----
-------------------------------

hl.window_rule({ match = { class = "^(Happ)$" },                  workspace = "1" })
hl.window_rule({ match = { class = "^(brave-browser)$" },         workspace = "4" })
hl.window_rule({ match = { class = "^(org.telegram.desktop)$" },  workspace = "5" })

-- Скрывает telegram от obs
hl.window_rule({
    match           = { class = "^(org\\.telegram\\.desktop)$" },
    no_screen_share = true,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mod  = "ALT"
local term = "alacritty"

-- на весь экран
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle", mode = "maximized" }))

-- скриншоты
hl.bind("Print",             hl.dsp.exec_cmd("grimshot copy area"))
hl.bind("SHIFT + Print",     hl.dsp.exec_cmd("grimshot copy screen"))
hl.bind("CTRL + Print",      hl.dsp.exec_cmd("grimshot copy active"))
hl.bind("CTRL + SHIFT + I",  hl.dsp.exec_cmd("grimshot copy area"))
hl.bind("CTRL + SHIFT + Cyrillic_sha", hl.dsp.exec_cmd("grimshot copy area"))

-- терминал / лаунчер / закрытие окна
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(term))
hl.bind(mod .. " + D",      hl.dsp.exec_cmd("noctalia msg panel-toggle launcher"))
hl.bind(mod .. " + Q",      hl.dsp.window.close())
-- жёсткое закрытие (убить процесс), если окно зависло
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.kill())

-- выход
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())

-- фокус между окнами (vim-style)
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "d" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "r" }))

-- перемещение окон
hl.bind(mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))
hl.bind(mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))

-- размер окна: ALT+- уменьшить, ALT++ увеличить (repeating = с повтором при удержании)
local shrink = { x = -80, y = -80, relative = true }
local grow   = { x =  80, y =  80, relative = true }

hl.bind(mod .. " + minus",        hl.dsp.window.resize(shrink), { repeating = true })
hl.bind(mod .. " + equal",        hl.dsp.window.resize(grow),   { repeating = true })
hl.bind(mod .. " + SHIFT + equal", hl.dsp.window.resize(grow),  { repeating = true })
-- numpad тоже:
hl.bind(mod .. " + KP_Subtract",  hl.dsp.window.resize(shrink), { repeating = true })
hl.bind(mod .. " + KP_Add",       hl.dsp.window.resize(grow),   { repeating = true })

-- рабочие столы
for i = 1, 7 do
    hl.bind(mod .. " + " .. i,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- перенос рабочего стола между мониторами
hl.bind(mod .. " + CTRL + L", hl.dsp.workspace.move({ monitor = "r" }))
hl.bind(mod .. " + CTRL + H", hl.dsp.workspace.move({ monitor = "l" }))

-- фикс столов после перетыкания HDMI (см. fix-monitor.sh).
-- ALT+SHIFT+F оставлен только под фуллскрин, иначе два действия на одной клавише.
hl.bind("CTRL + SHIFT + F", hl.dsp.exec_cmd("~/.config/hypr/fix-monitor.sh"))

-- громкость (vol.sh: дебаунс 100мс — клавиша дублируется двумя устройствами)
hl.bind(mod .. " + SHIFT + P", hl.dsp.exec_cmd("pavucontrol"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("/home/pc/bin/vol.sh up"),   { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("/home/pc/bin/vol.sh down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("/home/pc/bin/vol.sh mute"), { locked = true })
-- внешняя клавиатура CX 2.4G: F11/F12 как громкость (удержание работает через repeating)
hl.bind("F11", hl.dsp.exec_cmd("/home/pc/bin/vol.sh down"), { locked = true, repeating = true })
hl.bind("F12", hl.dsp.exec_cmd("/home/pc/bin/vol.sh up"),   { locked = true, repeating = true })

-- яркость (OSD показывает Noctalia)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("noctalia msg brightness-up"),   { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("noctalia msg brightness-down"), { locked = true })
hl.bind(mod .. " + 8", hl.dsp.exec_cmd("noctalia msg brightness-down"))
hl.bind(mod .. " + 9", hl.dsp.exec_cmd("noctalia msg brightness-up"))

-- быстрый запуск приложений (на Shift, чтобы Alt+T/B/P остались приложениям как Ctrl+T/B/P)
hl.bind(mod .. " + SHIFT + T", hl.dsp.exec_cmd("Telegram"))
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd("brave"))

-- как на маке: Alt работает как Ctrl для приложений (через sendshortcut в активное окно).
-- Свопа модификаторов больше нет: Alt=Alt, Ctrl=Ctrl. Система ест только свои клавиши
-- (Q закрыть, 1..7 столы, H/J/K/L фокус, D лаунчер), остальное уходит в приложения.
-- Исключения осознанно НЕ ремапим: Q (kill), D (лаунчер), H/J/K/L (фокус), цифры (столы).
-- ВАЖНО: в sendshortcut клавишу задаём кодом (code:NN), а не буквой!
-- Буква ищется по ТЕКУЩЕЙ раскладке клавиатуры: в RU латинской "a" нет ->
-- "sendshortcut: key not found" и нажатие молча съедается (Alt+A/C/V "не работают").
-- Код от раскладки не зависит вообще: A=38 B=56 C=54 E=26 F=41 G=42 I=31 M=58
-- N=57 O=32 P=33 R=27 S=39 T=28 U=30 V=55 W=25 X=53 Y=29 Z=52

-- копирование/вставка: в терминале Ctrl+Shift+C/V, везде иначе Ctrl+C/V.
-- В 0.57 hyprctl dispatch больше не принимает старый синтаксис, поэтому шлём
-- напрямую через Lua API (как Alt+W и остальные sendshortcut).
local function send_copy_paste(code)
    local win = hl.get_active_window()
    local is_terminal = win ~= nil and win.class ~= nil
        and win.class:lower():find("alacritty", 1, true) ~= nil

    hl.dispatch(hl.dsp.send_shortcut({
        mods   = is_terminal and "CTRL SHIFT" or "CTRL",
        key    = "code:" .. code,
        window = win,
    }))
end

hl.bind(mod .. " + C", function() send_copy_paste(54) end, { repeating = true })
hl.bind(mod .. " + V", function() send_copy_paste(55) end, { repeating = true })

local shortcuts = {
    ["X"] = 53,
    ["A"] = 38,
    ["Z"] = 52,
    ["SHIFT + Z"] = 29,
    ["T"] = 28,
    ["W"] = 25,
    ["N"] = 57,
    ["R"] = 27,
    ["F"] = 41,
    ["S"] = 39,
    ["P"] = 33,
    ["B"] = 56,
    ["U"] = 30,
    ["O"] = 32,
    ["E"] = 26,
    ["G"] = 42,
    ["I"] = 31,
    ["M"] = 58,
    ["Y"] = 29,
}

for key, code in pairs(shortcuts) do
    hl.bind(mod .. " + " .. key, hl.dsp.send_shortcut({
        mods   = "CTRL",
        key    = "code:" .. code,
        window = "activewindow",
    }), { repeating = true })
end

-- Noctalia панели вместо иконок в баре
hl.bind("CTRL + ALT + V",           hl.dsp.exec_cmd("noctalia msg panel-toggle clipboard"))
hl.bind("CTRL + SHIFT + bracketleft", hl.dsp.exec_cmd("noctalia msg panel-toggle session"))

-- протирка клавиатуры/тачпада 10 сек (см. clean-keyboard.sh, аналог sway events disabled)
-- ALT+Shift+P занят под pavucontrol, поэтому Ctrl+Shift+P
hl.bind("CTRL + SHIFT + P",            hl.dsp.exec_cmd("~/.config/hypr/clean-keyboard.sh"))
hl.bind("CTRL + SHIFT + Cyrillic_ze",  hl.dsp.exec_cmd("~/.config/hypr/clean-keyboard.sh")) -- та же P на RU-раскладке (З)
