#!/bin/bash
# ==========================================
# My personal configuration environment repo's installation script
# Copies configs FROM this repo TO their proper system locations
# ==========================================

set -o pipefail
shopt -s nullglob

# ask for sudo upfront
sudo -v
# kill su privilege on exit
trap 'sudo -k' EXIT

# --- COLORS ---
_BOLD_RED="\033[1;31m"
_GREEN="\033[0;32m"
_RESET="\033[0m"

# --- HELPER FUNCTIONS ---
alias ABONDONED='echo "[ABONDONED]:  " &&'

run() {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo -e "${_BOLD_RED}Error at line ${BASH_LINENO[0]}: command failed -> $*${_RESET}"
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
    local ask="$1"
    local out="$2"
    read -rp "$(echo -e "${_GREEN}:: ${_RESET}${ask} [Y/n] ")" "$out"
}
validator_regex='^[Yy]$|^$'

print_dots() {
    local iterations=3
    local delay=0.25
    local post_delay=0.35

    for ((i=0; i<iterations; i++)); do
        printf "."
        sleep $delay
    done
    sleep $post_delay
    printf "\r\033[K" # \033[K = ANSI clear to end of line
}

# --- SCRIPT DIR ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1


echo -e "${_GREEN}:: Installing configs from repo to system...${_RESET}"
preinstall_deps=""
prompt "Install Dependencies?" preinstall_deps

# preinstall dependencies
if [[ "$preinstall_deps" =~ $validator_regex ]]; then
    sudo pacman -S --needed \
        bash git paru \
        bat eza yazi micro keyd \
        kitty konsole code zed
    paru -S --needed \
        ttf-jetbrains-mono ttf-fira-code ttf-comic-mono-git ttf-comic-neue
        inter-font adobe-source-code-pro-fonts
fi

# ==========================================
# CONFIG FILES
# ==========================================
CONFIGD=$HOME/.config

mkdir -p "$CONFIGD/bashrc.d"

# copy configs from repo -> system
run command cp -rav -- "./bashrc.d"                  "$CONFIGD/bashrc.d/.."
# ABONDONED cpx -av -- "./xremap/config.yml"                   "$CONFIGD/xremap/config.yml"
scpx -av -- "./keyd/default.conf"                    "/etc/keyd/default.conf"
cpx -av -- "./vscode/settings.json"                  "$CONFIGD/$VSC_D/User/settings.json"
cpx -av -- "./vscode/keybindings.json"               "$CONFIGD/$VSC_D/User/keybindings.json"
cpx -av -- "./zed/settings.json"                     "$CONFIGD/zed/settings.json"
cpx -av -- "./zed/keymap.json"                       "$CONFIGD/zed/keymap.json"
cpx -av -- "./kitty/kitty.conf"                      "$CONFIGD/kitty/kitty.conf"
cpx -av -- "./kitty/keymap.conf"                     "$CONFIGD/kitty/keymap.conf"
cpx -av -- "./fastfetch/config.jsonc"                "$CONFIGD/fastfetch/config.jsonc"
cpx -av -- "./fastfetch/default.jsonc"               "$CONFIGD/fastfetch/default.jsonc"
# ABONDONED cpx -av -- "./lf/lfrc"                             "$CONFIGD/lf/lfrc"
cpx -av -- "./yazi/yazi.toml"                        "$CONFIGD/yazi/yazi.toml"
cpx -av -- "./micro/settings.json"                   "$CONFIGD/micro/settings.json"
cpx -av -- "./micro/bindings.json"                   "$CONFIGD/micro/bindings.json"
cpx -av -- "./bat/config"                            "$CONFIGD/bat/config"
cpx -av -- "./brave/Default/Preferences"             "$CONFIGD/BraveSoftware/Brave-Browser/Default/Preferences"
cpx -av -- "./clangd/config.yaml"                    "$CONFIGD/clangd/config.yaml"


# ==========================================
# DE CONFIGS
# ==========================================
KDE_CONF_D="$SCRIPT_DIR/KDE"

# ---- PLASMA
cpx -av -- "$KDE_CONF_D/plasma/Main.colors"          "$HOME/.local/share/color-schemes/Main.colors"
# cpx -av -- "$KDE_CONF_D/plasma/kglobalshortcutsrc"   "$CONFIGD/kglobalshortcutsrc"
# cpx -av -- "$KDE_CONF_D/plasma/khotkeysrc"           "$CONFIGD/khotkeysrc"

# ---- APPLICATIONS
# Konsole profiles
if [ -d "$KDE_CONF_D/applications/konsole" ]; then
    mkdir -p "$HOME/.local/share/konsole"
    run command cp -av -- "$KDE_CONF_D/applications/konsole/"* "$HOME/.local/share/konsole/" 2>/dev/null
fi

# Autostart
if [ -d "$KDE_CONF_D/applications/autostart" ]; then
    mkdir -p "$CONFIGD/autostart"
    run command cp -av -- "$KDE_CONF_D/applications/autostart/"* "$CONFIGD/autostart/" 2>/dev/null
fi

# Dolphin
if [ -f "$KDE_CONF_D/applications/dolphin/dolphinrc" ]; then
    cpx -av -- "$KDE_CONF_D/applications/dolphin/dolphinrc" "$CONFIGD/dolphinrc"
fi

# Gwenview
if [ -f "$KDE_CONF_D/applications/gwenview/gwenviewrc" ]; then
    cpx -av -- "$KDE_CONF_D/applications/gwenview/gwenviewrc" "$CONFIGD/gwenviewrc"
fi

# Haruna
if [ -d "$KDE_CONF_D/applications/haruna" ]; then
    mkdir -p "$CONFIGD/haruna"
    run command cp -av -- "$KDE_CONF_D/applications/haruna/"* "$CONFIGD/haruna/" 2>/dev/null
fi

# Krita
[ -f "$KDE_CONF_D/applications/krita/kritarc" ] && \
    cpx -av -- "$KDE_CONF_D/applications/krita/kritarc" "$CONFIGD/kritarc"
[ -f "$KDE_CONF_D/applications/krita/kritashortcutsrc" ] && \
    cpx -av -- "$KDE_CONF_D/applications/krita/kritashortcutsrc" "$CONFIGD/kritashortcutsrc"


echo -e "\n${_GREEN}Installation finished!${_RESET}"
postinstall_exec=""
prompt "Run postinstall?" postinstall_exec
# postinstall execution
if [[ "$postinstall_exec" =~ $validator_regex ]]; then
    systemctl enable --now keyd # enable keyd
    fc-cache -fv # for fonts to refresh
    echo -e "${_GREEN}Optional post-install execution finished!${_RESET}"
fi

echo -e "\n\n"; print_dots
echo -e "\033[0;36mYour system is ready to reflect configurations. Immediate reboot is optionally better!${_RESET}\n\n"
