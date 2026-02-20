#!/bin/bash
# ==========================================
# My personal configuration environment repo's installation script
# Copies configs FROM this repo TO their proper system locations
# apply-push.sh is the reverse of this script
# ==========================================

# --- COLORS ---
_BOLD_RED="\033[1;31m"
_GREEN="\033[0;32m"
_RESET="\033[0m"

# --- HELPER FUNCTIONS ---
run() {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo -e "${_BOLD_RED}❌ Error at line $LINENO: command failed -> $*${_RESET}"
    fi
}

# Copy with auto mkdir for destination
rcp() {
    local dest="${@: -1}"
    mkdir -p "$(dirname "$dest")"
    run command cp "$@"
}

# Same but with sudo
srcp() {
    local dest="${@: -1}"
    sudo mkdir -p "$(dirname "$dest")"
    run sudo cp "$@"
}

# --- SCRIPT DIR ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

echo -e "${_GREEN}:: Installing configs from repo to system...${_RESET}"

# ==========================================
# CONFIG FILES
# ==========================================
CONFIGD=$HOME/.config

# copy configs from repo -> system
run command cp -rav -- "./bashrc.d"                  "$CONFIGD/bashrc.d/.."
# rcp -av -- "./xremap/config.yml"                   "$CONFIGD/xremap/config.yml"
srcp -av -- "./keyd/default.conf"                    "/etc/keyd/default.conf"
rcp -av -- "./vscode/settings.json"                  "$CONFIGD/Code/User/settings.json"
rcp -av -- "./vscode/keybindings.json"               "$CONFIGD/Code/User/keybindings.json"
rcp -av -- "./zed/settings.json"                     "$CONFIGD/zed/settings.json"
rcp -av -- "./zed/keymap.json"                       "$CONFIGD/zed/keymap.json"
rcp -av -- "./kitty/kitty.conf"                      "$CONFIGD/kitty/kitty.conf"
rcp -av -- "./kitty/keymap.conf"                     "$CONFIGD/kitty/keymap.conf"
rcp -av -- "./fastfetch/config.jsonc"                "$CONFIGD/fastfetch/config.jsonc"
rcp -av -- "./fastfetch/default.jsonc"               "$CONFIGD/fastfetch/default.jsonc"
# rcp -av -- "./lf/lfrc"                             "$CONFIGD/lf/lfrc"
rcp -av -- "./yazi/yazi.toml"                        "$CONFIGD/yazi/yazi.toml"
rcp -av -- "./micro/settings.json"                   "$CONFIGD/micro/settings.json"
rcp -av -- "./micro/bindings.json"                   "$CONFIGD/micro/bindings.json"
rcp -av -- "./bat/config"                            "$CONFIGD/bat/config"


# ==========================================
# KDE CONFIGS
# ==========================================
KDE_CONF_D="$SCRIPT_DIR/KDE"

# ---- PLASMA
rcp -av -- "$KDE_CONF_D/plasma/Main.colors"          "$HOME/.local/share/color-schemes/Main.colors"

# ---- APPLICATIONS
# Konsole profiles
if [ -d "$KDE_CONF_D/applications/konsole" ]; then
    mkdir -p "$HOME/.local/share/konsole"
    run command cp -av -- "$KDE_CONF_D/applications/konsole/"* "$HOME/.local/share/konsole/" 2>/dev/null
fi

# KWin scripts
if [ -d "$KDE_CONF_D/applications/kwin/scripts" ]; then
    mkdir -p "$HOME/.local/share/kwin/scripts"
    run command cp -av -- "$KDE_CONF_D/applications/kwin/scripts/"* "$HOME/.local/share/kwin/scripts/" 2>/dev/null
fi

# Autostart
if [ -d "$KDE_CONF_D/applications/autostart" ]; then
    mkdir -p "$HOME/.config/autostart"
    run command cp -av -- "$KDE_CONF_D/applications/autostart/"* "$HOME/.config/autostart/" 2>/dev/null
fi


echo -e "\n${_GREEN}✅ Installation finished.${_RESET}"
echo "You may need to restart some applications for changes to take effect."
