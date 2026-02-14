#!/bin/bash
# ==========================================
# Apply & push configs (VSCode, Zed, Kitty, KDE, etc)
# Errors are printed in bold red, script continues
# ==========================================

# --- COLORS ---
BOLD_RED="\033[1;31m"
CLR_RESET="\033[0m"

# --- HELPER FUNCTION ---
# Run a command, if fails, print line in red, continue
run() {
    "$@"
    local status=$?
    if [ $status -ne 0 ]; then
        echo -e "${BOLD_RED}❌ Error at line $LINENO: command failed -> $*${CLR_RESET}"
    fi
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
# LF_CONFIG=$CONFIGD/lf/lfrc
YAZI_CONFIG=$CONFIGD/yazi/yazi.toml
MICRO_SETTINGS=$CONFIGD/micro/settings.json
MICRO_KEYMAP=$CONFIGD/micro/bindings.json

# copy configs
run cp -rav -- "$BASH_CONFIG_DIR"	"./bashrc.d/.."
# run cp -av -- "$XREMAP_CONFIG"     "./xremap/config.yml"
run sudo cp -av -- "$KEYD_CONFIG"	"./keyd/default.conf"
run cp -av -- "$VSCODE_SETTINGS"   "./vscode/settings.json"
run cp -av -- "$VSCODE_KEYMAP"     "./vscode/keybindings.json"
run cp -av -- "$ZED_SETTINGS"      "./zed/settings.json"
run cp -av -- "$ZED_KEYMAP"        "./zed/keymap.json"
run cp -av -- "$KITTY_SETTINGS"    "./kitty/kitty.conf"
run cp -av -- "$KITTY_KEYMAP"      "./kitty/keymap.conf"
run cp -av -- "$FASTFETCH_CONFIG"  "./fastfetch/config.jsonc"
# run cp -av -- "$LF_CONFIG" 		"./lf/lfrc"
run cp -av -- "$YAZI_CONFIG"		"./yazi/yazi.toml"
run cp -av -- "$MICRO_SETTINGS" 	"./micro/settings.json"
run cp -av -- "$MICRO_KEYMAP" 		"./micro/bindings.json"

# ==========================================
# KDE CONFIGS
# ==========================================
KDE_REPO_DIR="$HOME/Documents/configs/KDE"
mkdir -p "$KDE_REPO_DIR"/{plasma,applications}

# plasma files
PLASMA_FILES=(

)

for f in "${PLASMA_FILES[@]}"; do
    src="$HOME/.config/$f"
    if [ -f "$src" ]; then
        run cp -v -- "$src" "$KDE_REPO_DIR/plasma/$f"
    fi
done

# ---- APPLICATION files
# Konsole profiles
if [ -d "$HOME/.local/share/konsole" ]; then
    mkdir -p "$KDE_REPO_DIR/applications/konsole"
    run cp -av -- "$HOME/.local/share/konsole/"* "$KDE_REPO_DIR/applications/konsole/" 2>/dev/null
fi

# KWin scripts
if [ -d "$HOME/.local/share/kwin/scripts" ]; then
    mkdir -p "$KDE_REPO_DIR/applications/kwin/scripts"
    run cp -av -- "$HOME/.local/share/kwin/scripts/"* "$KDE_REPO_DIR/applications/kwin/scripts/" 2>/dev/null
fi

# Autostart
if [ -d "$HOME/.config/autostart" ]; then
    mkdir -p "$KDE_REPO_DIR/applications/autostart"
    run cp -av -- "$HOME/.config/autostart/"* "$KDE_REPO_DIR/applications/autostart/" 2>/dev/null
fi

# Common app rc files
declare -A APP_FILES=(

)

for app in "${!APP_FILES[@]}"; do
    src="${APP_FILES[$app]}"
    if [ -f "$src" ]; then
        mkdir -p "$KDE_REPO_DIR/applications/$app"
        run cp -v -- "$src" "$KDE_REPO_DIR/applications/$app/$(basename "$src")"
    fi
done

# ---- .gitignore for KDE
GITIGNORE="$KDE_REPO_DIR/.gitignore"
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
REPO_URL="https://github.com/Monjaris/My-Configs.git"
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
