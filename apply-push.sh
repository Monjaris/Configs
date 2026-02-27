#!/bin/bash
# ==========================================
# My personal configuration enviroment repo's applying and pushing script
# Installation script is in the same directory (install.sh)
# ==========================================

# --- COLORS ---
_BOLD_RED="\033[1;31m"
_RESET="\033[0m"

# printf "$_BOLD_RED\nFIX FIRST!!!\n"
# exit

# --- HELPER FUNCTION ---
# Run a command, if fails, print line in red, continue
run() {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo -e "${_BOLD_RED}❌ Error at line $LINENO: command failed -> $*${_RESET}"
    fi
}

# Copy with auto mkdir for destination — grabs last arg as destination path
rcp() {
    local dest="${@: -1}"
    mkdir -p "$(dirname "$dest")"
    run command cp "$@"
}

# Same as above but with sudo for root-owned files
su_rcp() {
    local dest="${@: -1}"
    mkdir -p "$(dirname "$dest")"
    run sudo cp "$@"
}


# --- SCRIPT DIR ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# ==========================================
# CONFIG FILES
# ==========================================
CONFIGD=$HOME/.config

## PROGRAMS
BASH_CONFIG_DIR=$CONFIGD/bashrc.d
# XREMAP_CONFIG=$CONFIGD/xremap/config.yml
KEYD_CONFIG=/etc/keyd/default.conf
VSCODE_SETTINGS=$CONFIGD/Code/User/settings.json
VSCODE_KEYMAP=$CONFIGD/Code/User/keybindings.json
ZED_SETTINGS=$CONFIGD/zed/settings.json
ZED_KEYMAP=$CONFIGD/zed/keymap.json
KITTY_SETTINGS=$CONFIGD/kitty/kitty.conf
KITTY_KEYMAP=$CONFIGD/kitty/keymap.conf
FASTFETCH_CONFIG=$CONFIGD/fastfetch/config.jsonc
FASTFETCH_DEFAULT=$CONFIGD/fastfetch/default.jsonc
# LF_CONFIG=$CONFIGD/lf/lfrc
YAZI_CONFIG=$CONFIGD/yazi/yazi.toml
MICRO_SETTINGS=$CONFIGD/micro/settings.json
MICRO_KEYMAP=$CONFIGD/micro/bindings.json
BAT_CONFIG=$CONFIGD/bat/config

# copy configs
run command cp -rav -- "$BASH_CONFIG_DIR"   "./bashrc.d/.."
# rcp -av -- "$XREMAP_CONFIG"               "./xremap/config.yml"
su_rcp -av -- "$KEYD_CONFIG"                 "./keyd/default.conf"
rcp -av -- "$VSCODE_SETTINGS"              "./vscode/settings.json"
rcp -av -- "$VSCODE_KEYMAP"               "./vscode/keybindings.json"
rcp -av -- "$ZED_SETTINGS"                "./zed/settings.json"
rcp -av -- "$ZED_KEYMAP"                  "./zed/keymap.json"
rcp -av -- "$KITTY_SETTINGS"              "./kitty/kitty.conf"
rcp -av -- "$KITTY_KEYMAP"               "./kitty/keymap.conf"
rcp -av -- "$FASTFETCH_CONFIG"            "./fastfetch/config.jsonc"
rcp -av -- "$FASTFETCH_DEFAULT"           "./fastfetch/default.jsonc"
# rcp -av -- "$LF_CONFIG"                  "./lf/lfrc"
rcp -av -- "$YAZI_CONFIG"                 "./yazi/yazi.toml"
rcp -av -- "$MICRO_SETTINGS"              "./micro/settings.json"
rcp -av -- "$MICRO_KEYMAP"               "./micro/bindings.json"
rcp -av -- "$BAT_CONFIG"                  "./bat/config"


# ==========================================
# KDE CONFIGS
# ==========================================
KDE_CONF_D="$HOME/Documents/configs/KDE"
mkdir -p "$KDE_CONF_D"/{plasma,applications}


# ---- PLASMA (D.E. config files)
rcp -av -- "$HOME/.local/share/color-schemes/Main.colors" "$KDE_CONF_D/plasma/Main.colors"


# ---- APPLICATIONs
# Konsole profiles
if [ -d "$HOME/.local/share/konsole" ]; then
    mkdir -p "$KDE_CONF_D/applications/konsole"
    run command cp -av -- "$HOME/.local/share/konsole/"* "$KDE_CONF_D/applications/konsole/" 2>/dev/null
fi
# KWin scripts
if [ -d "$HOME/.local/share/kwin/scripts" ]; then
    mkdir -p "$KDE_CONF_D/applications/kwin/scripts"
    run command cp -av -- "$HOME/.local/share/kwin/scripts/"* "$KDE_CONF_D/applications/kwin/scripts/" 2>/dev/null
fi
# Autostart
if [ -d "$HOME/.config/autostart" ]; then
    mkdir -p "$KDE_CONF_D/applications/autostart"
    run command cp -av -- "$HOME/.config/autostart/"* "$KDE_CONF_D/applications/autostart/" 2>/dev/null
fi


# ---- .gitignore for KDE
GITIGNORE="$KDE_CONF_D/.gitignore"
if [ ! -f "$GITIGNORE" ]; then
    cat > "$GITIGNORE" <<'EOT'
# ignore hardware-specific and cache stuff
plasma-org.kde.plasma.desktop-appletsrc
.local/share/kscreen/
.config/kscreen*
**/session/
**/cache/
**/thumbnails/
kwallet*
EOT
    echo "[kde-export] created .gitignore"
fi

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
    echo "[git] committing"
    run git commit -m "$COMMIT_MSG"
else
    echo "[git] nothing to commit"
fi

# push
echo "[git] pushing to $BRANCH"
run git push -u origin "$BRANCH"

echo -e "\n✅ Apply & push script finished."
