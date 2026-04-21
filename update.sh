#!/bin/bash
# ==========================================
# My personal configuration environment repo's update script
# Copies configs FROM system TO this repo, then git pushes
# ==========================================

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
alias ABONDONED='echo "[ABONDONED]:  " &&'

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

BASH_CONFIG_DIR=$CONFIGD/bashrc.d
XREMAP_CONFIG=$CONFIGD/xremap/config.yml # abondoned
KEYD_CONFIG=/etc/keyd/default.conf
VSCODE_SETTINGS="$CONFIGD/Code - OSS/User/settings.json"
VSCODE_KEYMAP="$CONFIGD/Code - OSS/User/keybindings.json"
ZED_SETTINGS=$CONFIGD/zed/settings.json
ZED_KEYMAP=$CONFIGD/zed/keymap.json
KITTY_SETTINGS=$CONFIGD/kitty/kitty.conf
KITTY_KEYMAP=$CONFIGD/kitty/keymap.conf
FASTFETCH_CONFIG=$CONFIGD/fastfetch/config.jsonc
FASTFETCH_DEFAULT=$CONFIGD/fastfetch/default.jsonc
LF_CONFIG=$CONFIGD/lf/lfrc # abondoned
YAZI_CONFIG=$CONFIGD/yazi/yazi.toml
MICRO_SETTINGS=$CONFIGD/micro/settings.json
MICRO_KEYMAP=$CONFIGD/micro/bindings.json
BAT_CONFIG=$CONFIGD/bat/config
BRAVE_PREFS=$CONFIGD/BraveSoftware/Brave-Browser/Default/Preferences
CLANGD_CONFIG=$CONFIGD/clangd/config.yaml

run command cp -rav -- "$BASH_CONFIG_DIR"      "./bashrc.d/.."
ABONDONED rcp -av -- "$XREMAP_CONFIG"                  "./xremap/config.yml"
su_rcp -av -- "$KEYD_CONFIG"                   "./keyd/default.conf"
rcp -av -- "$VSCODE_SETTINGS"                  "./vscode/settings.json"
rcp -av -- "$VSCODE_KEYMAP"                    "./vscode/keybindings.json"
rcp -av -- "$ZED_SETTINGS"                     "./zed/settings.json"
rcp -av -- "$ZED_KEYMAP"                       "./zed/keymap.json"
rcp -av -- "$KITTY_SETTINGS"                   "./kitty/kitty.conf"
rcp -av -- "$KITTY_KEYMAP"                     "./kitty/keymap.conf"
rcp -av -- "$FASTFETCH_CONFIG"                 "./fastfetch/config.jsonc"
rcp -av -- "$FASTFETCH_DEFAULT"                "./fastfetch/default.jsonc"
ABONDONED rcp -av -- "$LF_CONFIG"                      "./lf/lfrc"
rcp -av -- "$YAZI_CONFIG"                      "./yazi/yazi.toml"
rcp -av -- "$MICRO_SETTINGS"                   "./micro/settings.json"
rcp -av -- "$MICRO_KEYMAP"                     "./micro/bindings.json"
rcp -av -- "$BAT_CONFIG"                       "./bat/config"
rcp -av -- "$BRAVE_PREFS"                      "./brave/Default/Preferences"
rcp -av -- "$CLANGD_CONFIG"                    "./clangd/config.yaml"

# Autostart
if [ -d "$CONFIGD/autostart" ]; then
    mkdir -p "./autostart"
    run command cp -av -- "$CONFIGD/autostart/"* "./autostart/" 2>/dev/null
fi


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
rcp -av -- "$HOME/.local/share/color-schemes/Main.colors" "$KDE_CONF_D/plasma/Main.colors"
rcp -av -- "$CONFIGD/xsettingsd/xsettingsd.conf"          "$KDE_CONF_D/plasma/xsettingsd.conf"
rcp -av -- "$CONFIGD/kglobalshortcutsrc"                  "$KDE_CONF_D/plasma/kglobalshortcutsrc"
rcp -av -- "$CONFIGD/kcminputrc"                          "$KDE_CONF_D/plasma/kcminputrc"
rcp -av -- "$CONFIGD/kdeglobals"                          "$KDE_CONF_D/plasma/kdeglobals"
rcp -av -- "$CONFIGD/krunnerrc"                           "$KDE_CONF_D/plasma/krunnerrc"
rcp -av -- "$CONFIGD/breezerc"                            "$KDE_CONF_D/plasma/breezerc"
rcp -av -- "$CONFIGD/kwinrc"                              "$KDE_CONF_D/plasma/kwinrc"

# ---- APPLICATIONS
# Konsole profiles
if [ -d "$HOME/.local/share/konsole" ]; then
    run command cp -av -- "$HOME/.local/share/konsole/"* "$KDE_CONF_D/applications/konsole/" 2>/dev/null
fi

# KWin scripts
if [ -d "$HOME/.local/share/kwin/scripts" ]; then
    run command cp -av -- "$HOME/.local/share/kwin/scripts/"* "$KDE_CONF_D/applications/kwin/scripts/" 2>/dev/null
fi

# Dolphin
[ -f "$CONFIGD/dolphinrc" ] && rcp -av -- "$CONFIGD/dolphinrc" "$KDE_CONF_D/applications/dolphin/dolphinrc"

# Gwenview
[ -f "$CONFIGD/gwenviewrc" ] && rcp -av -- "$CONFIGD/gwenviewrc" "$KDE_CONF_D/applications/gwenview/gwenviewrc"

# Haruna
if [ -d "$CONFIGD/haruna" ]; then
    run command cp -av -- "$CONFIGD/haruna/"* "$KDE_CONF_D/applications/haruna/" 2>/dev/null
fi

# Krita
[ -f "$CONFIGD/kritarc" ] && rcp -av -- "$CONFIGD/kritarc" "$KDE_CONF_D/applications/krita/kritarc"


# ==========================================
# GIT PUSH
# ==========================================
REPO_URL="https://github.com/Monjaris/Configs.git"
BRANCH="main"

# init git if missing
if [ ! -d ".git" ]; then
    echo ":: [git] initializing repository"
    run git init
    run git branch -M "$BRANCH"
fi

# add remote if missing
if ! git remote | grep -q "^origin$"; then
    echo ":: [git] adding origin remote"
    run git remote add origin "$REPO_URL"
fi

# update remote URL in case it's stale
run git remote set-url origin "$REPO_URL"

# stage all files
echo ":: [git] staging files"
run git add .

# commit only if changes exist
if ! git diff --cached --quiet; then
    COMMIT_MSG="update configs: $(date '+%Y-%m-%d %H:%M')"
    echo ":: [git] committing"
    run git commit -m "$COMMIT_MSG"
else
    echo ":: [git] nothing to commit"
fi

# push
echo ":: [git] pushing to $BRANCH"
run git push -u origin "$BRANCH"

echo -e "\nUpdate & push finished."
