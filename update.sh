#!/bin/bash
# ==============================================================
# My personal configuration environment directory update script
# ==============================================================

set -o pipefail
shopt -s nullglob


# ask for sudo upfront
sudo -v
# kill su privilege on exit
trap 'sudo -k' EXIT

# --- COLORS ---
_BOLD_RED="\033[1;31m"
_RESET="\033[0m"

# --- HELPER FUNCTIONS ---

run() {
    "$@" || echo -e "${_BOLD_RED}Error at line ${BASH_LINENO[0]}: $*${_RESET}"
}

# Copy with auto mkdir for destination
rcp() {
    local dest="${@: -1}"
    mkdir -p "$(dirname "$dest")"
    run command cp "$@"
}

# Same but with sudo for root-owned files — chowns dest back so git can stage it
su_rcp() {
    local dest="${@: -1}"
    mkdir -p "$(dirname "$dest")"
    run sudo cp "$@"
    run sudo chown "$USER:$USER" "$dest"
}

# --- SCRIPT DIR ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# ==========================================
# CONFIG FILES
# ==========================================
CONFIGD=$HOME/.config
VSC="Code - OSS"
AUR_H="yay"

BASH_CONFIG_DIR=$CONFIGD/bashrc.d
XREMAP_CONFIG=$CONFIGD/xremap/config.yml # abondoned
KEYD_CONFIG=/etc/keyd/default.conf
VSCODE_SETTINGS="$CONFIGD/$VSC/User/settings.json"
VSCODE_KEYMAP="$CONFIGD/$VSC/User/keybindings.json"
ZED_SETTINGS=$CONFIGD/zed/settings.json
ZED_KEYMAP=$CONFIGD/zed/keymap.json
ZED_THEME_D=$CONFIGD/zed/extensions/one-dark-pro-clean
KITTY_SETTINGS=$CONFIGD/kitty/kitty.conf
KITTY_KEYMAP=$CONFIGD/kitty/keymap.conf
AUR_HELPER=$CONFIGD/$AUR_H/config.json
FASTFETCH_CONFIG=$CONFIGD/fastfetch/config.jsonc
FASTFETCH_DEFAULT=$CONFIGD/fastfetch/default.jsonc
LF_CONFIG=$CONFIGD/lf/lfrc # abondoned
YAZI_CONFIG=$CONFIGD/yazi/yazi.toml
MICRO_SETTINGS=$CONFIGD/micro/settings.json
MICRO_KEYMAP=$CONFIGD/micro/bindings.json
BAT_CONFIG=$CONFIGD/bat/config
BRAVE_PREFS=$CONFIGD/BraveSoftware/Brave-Browser/Default/Preferences
CLANGD_CONFIG=$CONFIGD/clangd/config.yaml

ENVD="environment"
run command cp -avu -- "$HOME/bin/"*             "./$ENVD/bin/"
run command cp -avu -- "$CONFIGD/autostart/"*    "./$ENVD/autostart/"
run command cp -avu -- "$BASH_CONFIG_DIR/"*      "./$ENVD/bashrc.d/"


# ABONDONED rcp -avu -- "$XREMAP_CONFIG"                  "./xremap/config.yml"
su_rcp -avu -- "$KEYD_CONFIG"                   "./keyd/default.conf"
rcp -avu -- "$VSCODE_SETTINGS"                  "./vscode/settings.json"
rcp -avu -- "$VSCODE_KEYMAP"                    "./vscode/keybindings.json"
rcp -avu -- "$ZED_SETTINGS"                     "./zed/settings.json"
rcp -avu -- "$ZED_KEYMAP"                       "./zed/keymap.json"
run command cp -ravu -- "$ZED_THEME_D/"*        "./zed/extensions/one-dark-pro-clean/"
rcp -avu -- "$KITTY_SETTINGS"                   "./kitty/kitty.conf"
rcp -avu -- "$KITTY_KEYMAP"                     "./kitty/keymap.conf"
rcp -avu -- "$AUR_HELPER"                     "./$AUR_H/config.json"
rcp -avu -- "$FASTFETCH_CONFIG"                 "./fastfetch/config.jsonc"
rcp -avu -- "$FASTFETCH_DEFAULT"                "./fastfetch/default.jsonc"
# ABONDONED rcp -avu -- "$LF_CONFIG"                      "./lf/lfrc"
rcp -avu -- "$YAZI_CONFIG"                      "./yazi/yazi.toml"
rcp -avu -- "$MICRO_SETTINGS"                   "./micro/settings.json"
rcp -avu -- "$MICRO_KEYMAP"                     "./micro/bindings.json"
rcp -avu -- "$BAT_CONFIG"                       "./bat/config"
rcp -avu -- "$BRAVE_PREFS"                      "./brave/Default/Preferences"
rcp -avu -- "$CLANGD_CONFIG"                    "./clangd/config.yaml"


# ==========================================
# DE CONFIGS
# ==========================================
# NOTE: KDE_CONF_D must be defined before any block that uses it
KDE_CONF_D="$SCRIPT_DIR/KDE"

mkdir -p \
    "$KDE_CONF_D/plasma" \
    "$KDE_CONF_D/applications/konsole" \
    "$KDE_CONF_D/applications/kwin/scripts" \
    "$KDE_CONF_D/applications/dolphin" \
    "$KDE_CONF_D/applications/gwenview" \
    "$KDE_CONF_D/applications/haruna" \
    "$KDE_CONF_D/applications/krita"

# ---- PLASMA
rcp -avu -- "$HOME/.local/share/color-schemes/Main.colors" "$KDE_CONF_D/plasma/Main.colors"
rcp -avu -- "$CONFIGD/xsettingsd/xsettingsd.conf"          "$KDE_CONF_D/plasma/xsettingsd.conf"
rcp -avu -- "$CONFIGD/kglobalshortcutsrc"                  "$KDE_CONF_D/plasma/kglobalshortcutsrc"
rcp -avu -- "$CONFIGD/kcminputrc"                          "$KDE_CONF_D/plasma/kcminputrc"
rcp -avu -- "$CONFIGD/kdeglobals"                          "$KDE_CONF_D/plasma/kdeglobals"
rcp -avu -- "$CONFIGD/krunnerrc"                           "$KDE_CONF_D/plasma/krunnerrc"
rcp -avu -- "$CONFIGD/breezerc"                            "$KDE_CONF_D/plasma/breezerc"
rcp -avu -- "$CONFIGD/kwinrc"                              "$KDE_CONF_D/plasma/kwinrc"

# ---- APPLICATIONS
# Konsole profiles
if [ -d "$HOME/.local/share/konsole" ]; then
    run command cp -avu -- "$HOME/.local/share/konsole/"* "$KDE_CONF_D/applications/konsole/"
fi

# KWin scripts
if [ -d "$HOME/.local/share/kwin/scripts" ]; then
    run command cp -avu -- "$HOME/.local/share/kwin/scripts/"* "$KDE_CONF_D/applications/kwin/scripts/"
fi

# Dolphin
[ -f "$CONFIGD/dolphinrc" ] && rcp -avu -- "$CONFIGD/dolphinrc" "$KDE_CONF_D/applications/dolphin/dolphinrc"

# Gwenview
[ -f "$CONFIGD/gwenviewrc" ] && rcp -avu -- "$CONFIGD/gwenviewrc" "$KDE_CONF_D/applications/gwenview/gwenviewrc"

# Haruna
if [ -d "$CONFIGD/haruna" ]; then
    run command cp -avu -- "$CONFIGD/haruna/"* "$KDE_CONF_D/applications/haruna/"
fi

# Krita
[ -f "$CONFIGD/kritarc" ]           && rcp -avu -- "$CONFIGD/kritarc"           "$KDE_CONF_D/applications/krita/kritarc"
[ -f "$CONFIGD/kritashortcutsrc" ]  && rcp -avu -- "$CONFIGD/kritashortcutsrc"  "$KDE_CONF_D/applications/krita/kritashortcutsrc"
