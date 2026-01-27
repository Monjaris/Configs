#!/bin/bash

# === APPLY ===

CONFIGD="$HOME/.config"
VSCODE_SETTINGS="$CONFIGD/Code/User/settings.json"
VSCODE_KEYMAP="$CONFIGD/Code/User/keybindings.json"
ZED_SETTINGS="$CONFIGD/zed/settings.json"
ZED_KEYMAP="$CONFIGD/zed/keymap.json"
KITTY_SETTINGS="$CONFIGD/kitty/kitty.conf"
KITTY_KEYMAP="$CONFIGD/kitty/keymap.conf"
XREMAP_CONFIG="$CONFIGD/xremap/config.yml"
FASTFETCH_CONFIG="$CONFIGD/fastfetch/config.jsonc"

cp "$VSCODE_SETTINGS"   "./vscode/settings.json"
cp "$VSCODE_KEYMAP"     "./vscode/keybindings.json"
cp "$ZED_SETTINGS"      "./zed/settings.json"
cp "$ZED_KEYMAP"        "./zed/keymap.json"
cp "$KITTY_SETTINGS"    "./kitty/kitty.conf"
cp "$KITTY_KEYMAP"      "./kitty/keymap.conf"
cp "$XREMAP_CONFIG"     "./xremap/config.yml"
cp "$FASTFETCH_CONFIG"  "./fastfetch/config.jsonc"


# === PUSH ===

REPO_URL="https://github.com/Monjaris/My-Configs.git"
BRANCH="main"

# go to the directory this script runs
cd "$(dirname "$0")" || exit 1

# init git if not already
if [ ! -d ".git" ]; then
    echo ":: [git] initializing repository"
    git init
    git branch -M "$BRANCH"
fi

# add remote if missing
if ! git remote | grep -q "^origin$"; then
    echo ":: [git] adding origin remote"
    git remote add origin "$REPO_URL"
fi

# stage all tracked + new files
echo ":: [git] staging files"
git add .

# commit only if there are changes
if ! git diff --cached --quiet; then
    COMMIT_MSG="update configs: $(date '+%Y-%m-%d %H:%M')"
    echo "[git] committing"
    git commit -m "$COMMIT_MSG"
else
    echo "[git] nothing to commit"
fi

# push
echo "[git] pushing to $BRANCH"
git push -u origin "$BRANCH"

