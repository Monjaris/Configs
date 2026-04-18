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
        echo -e "${_BOLD_RED}❌ Error at line ${BASH_LINENO[0]}: command failed -> $*${_RESET}"
    fi
}

# Copy with auto mkdir for destination
cpx() {
    local dest="${@: -1}"
    mkdir -p "$(dirname "$dest")"
    run command cp "$@"
}

# Same but with sudo
scpx() {
    local dest="${@: -1}"
    sudo mkdir -p "$(dirname "$dest")"
    run sudo cp "$@"
}

prompt() {
    local out="$1"
    read -rp "$(echo -e "${_GREEN}:: ${_RESET}Install Dependencies? [Y/n] ")" "$out"
}
alias validator_regex='^[Yy]$|^$'

# --- SCRIPT DIR ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

echo -e "${_GREEN}:: Installing configs from repo to system...${_RESET}"

preinstall_deps="N"
prompt "$preinstall_deps"

if [[ "$preinstall_deps" =~ "$validator_regex" ]]; then
    sudo pacman -S --needed \
        bash bat eza yazi micro keyd \
        kitty konsole code code-martkeplace zed

    # Install fonts
    paru -S --needed ttf-jetbrains-mono otf-jetbrains-mono \
        sudo pacman -S --needed ttf-jetbrains-mono \
        echo -e "${_BOLD_RED}Fonts not found in repos, skipping...${_RESET}"
fi

# ==========================================
# CONFIG FILES
# ==========================================
CONFIGD=$HOME/.config

# create folders which may have not be there already
mkdir -p "$CONFIGD/.bashrc.d"
# mkdir -p "$CONFIGD/fastfetch"
# mkdir -p "$CONFIGD/yazi"
# mkdir -p "$CONFIGD/bat"

# copy configs from repo -> system
run command cp -rav -- "./bashrc.d"                  "$CONFIGD/bashrc.d/.."
# cpx -av -- "./xremap/config.yml"                   "$CONFIGD/xremap/config.yml"
scpx -av -- "./keyd/default.conf"                    "/etc/keyd/default.conf"
cpx -av -- "./vscode/settings.json"                  "$CONFIGD/Code/User/settings.json"
cpx -av -- "./vscode/keybindings.json"               "$CONFIGD/Code/User/keybindings.json"
cpx -av -- "./zed/settings.json"                     "$CONFIGD/zed/settings.json"
cpx -av -- "./zed/keymap.json"                       "$CONFIGD/zed/keymap.json"
cpx -av -- "./kitty/kitty.conf"                      "$CONFIGD/kitty/kitty.conf"
cpx -av -- "./kitty/keymap.conf"                     "$CONFIGD/kitty/keymap.conf"
cpx -av -- "./fastfetch/config.jsonc"                "$CONFIGD/fastfetch/config.jsonc"
cpx -av -- "./fastfetch/default.jsonc"               "$CONFIGD/fastfetch/default.jsonc"
# cpx -av -- "./lf/lfrc"                             "$CONFIGD/lf/lfrc"
cpx -av -- "./yazi/yazi.toml"                        "$CONFIGD/yazi/yazi.toml"
cpx -av -- "./micro/settings.json"                   "$CONFIGD/micro/settings.json"
cpx -av -- "./micro/bindings.json"                   "$CONFIGD/micro/bindings.json"
cpx -av -- "./bat/config"                            "$CONFIGD/bat/config"
cpx -av -- "./brave/Default/Preferences"              "$CONFIGD/BraveSoftware/Brave-Browser"


# ==========================================
# KDE CONFIGS
# ==========================================
KDE_CONF_D="$SCRIPT_DIR/KDE"

# ---- PLASMA
cpx -av -- "$KDE_CONF_D/plasma/Main.colors"          "$HOME/.local/share/color-schemes/Main.colors"

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
