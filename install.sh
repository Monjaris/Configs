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
    read -rp "$(echo -e "${_GREEN}:: ${_RESET}${ask}")" "$out"
}
validator_regex='^[Yy]$|^$'

enable_service() {
    local service="$1"
    echo "Enabling service: $service..."
    systemctl is-enabled --quiet "$service" || sudo systemctl enable --now "$service"
}

handle_finish () {
    local action
    while true; do
        prompt "Press enter to log-out, 'r' to reboot or 'a' to abort: " action
        case "$action" in
            "")
                loginctl terminate-session "$XDG_SESSION_ID"
                break
                ;;
            r)
                systemctl reboot
                break
                ;;
            a)
                echo "Aborted."
                break
                ;;
            *)
                echo -e "${_BOLD_RED}Invalid input. Enter nothing, 'r', or 'a'.${_RESET}"
                ;;
        esac
    done
}

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
prompt "Install Dependencies? [y/N] " preinstall_deps

# preinstall dependencies
if [[ "$preinstall_deps" =~ $validator_regex ]]; then
    sudo pacman -S --needed git base-devel man-db
    # install yay via chaotic-aur if not already present
    if ! command -v yay &>/dev/null; then
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB
        sudo pacman-key --populate
        sudo pacman -U --noconfirm \
            'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        sudo pacman -U --noconfirm \
            'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
        # append chaotic-aur to pacman.conf if not already there
        if ! grep -q '^\[chaotic-aur\]' /etc/pacman.conf; then
            sudo tee -a /etc/pacman.conf > /dev/null <<'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF
        fi
        sudo pacman -Sy
        sudo pacman -S --needed yay
    fi
    # install other packages
    sudo pacman -S --needed \
        bat eza yazi micro keyd \
        kitty konsole code zed
    # install the ones from AUR
    yay -S --needed \
        ttf-jetbrains-mono ttf-fira-code ttf-comic-mono-git ttf-comic-neue \
        inter-font adobe-source-code-pro-fonts
fi

# ==========================================
# CONFIG FILES
# ==========================================
# copy configs from repo -> system

CONFIGD=$HOME/.config


mkdir -p "$HOME/bin"
mkdir -p "$CONFIGD/autostart"
mkdir -p "$CONFIGD/bashrc.d"
# Copy environment files to their corresponding places
ENVD="environment"
run  command cp -rav -- "$ENVD/bin"/*         "$HOME/bin"
run command cp -rav -- "$ENVD/autostart/"*   "$CONFIGD/autostart/"
run command cp -rav -- "$ENVD/bashrc.d/"*    "$CONFIGD/bashrc.d/"


# ABONDONED cpx -av -- "./xremap/config.yml"                  "$CONFIGD/xremap/config.yml"
scpx -av -- "./keyd/default.conf"                    "/etc/keyd/default.conf"
VSC="Code - OSS"; cpx -av -- "./vscode/settings.json" "$CONFIGD/$VSC/User/settings.json"
cpx -av -- "./vscode/keybindings.json"                "$CONFIGD/$VSC/User/keybindings.json"
cpx -av -- "./zed/settings.json"                      "$CONFIGD/zed/settings.json"
cpx -av -- "./zed/keymap.json"                        "$CONFIGD/zed/keymap.json"
cpx -rav -- "./zed/extensions/one-dark-pro-clean"     "$CONFIGD/zed/extensions/one-dark-pro-clean"
cpx -av -- "./kitty/kitty.conf"                       "$CONFIGD/kitty/kitty.conf"
cpx -av -- "./kitty/keymap.conf"                      "$CONFIGD/kitty/keymap.conf"
AUR_HELPER="yay"; cpx -av -- "./$AUR_HELPER/config.json" "$CONFIGD/$AUR_HELPER/config.json"
cpx -av -- "./fastfetch/config.jsonc"                 "$CONFIGD/fastfetch/config.jsonc"
cpx -av -- "./fastfetch/default.jsonc"                "$CONFIGD/fastfetch/default.jsonc"
# ABONDONED cpx -av -- "./lf/lfrc"                             "$CONFIGD/lf/lfrc"
cpx -av -- "./yazi/yazi.toml"                         "$CONFIGD/yazi/yazi.toml"
cpx -av -- "./micro/settings.json"                    "$CONFIGD/micro/settings.json"
cpx -av -- "./micro/bindings.json"                    "$CONFIGD/micro/bindings.json"
cpx -av -- "./bat/config"                             "$CONFIGD/bat/config"
cpx -av -- "./brave/Default/Preferences" "$CONFIGD/BraveSoftware/Brave-Browser/Default/Preferences"
cpx -av -- "./clangd/config.yaml"                     "$CONFIGD/clangd/config.yaml"


# ==========================================
# DE CONFIGS
# ==========================================
KDE_CONF_D="$SCRIPT_DIR/KDE"

# ---- PLASMA
cpx -av -- "$KDE_CONF_D/plasma/Main.colors"          "$HOME/.local/share/color-schemes/Main.colors"
cpx -av -- "$KDE_CONF_D/plasma/xsettingsd.conf"    "$CONFIGD/xsettingsd/xsettingsd.conf"
cpx -av -- "$KDE_CONF_D/plasma/kglobalshortcutsrc"   "$CONFIGD/kglobalshortcutsrc"
cpx -av -- "$KDE_CONF_D/plasma/kcminputrc"           "$CONFIGD/kcminputrc"
cpx -av -- "$KDE_CONF_D/plasma/kdeglobals"           "$CONFIGD/kdeglobals"
cpx -av -- "$KDE_CONF_D/plasma/krunnerrc"            "$CONFIGD/krunnerrc"
cpx -av -- "$KDE_CONF_D/plasma/breezerc"             "$CONFIGD/breezerc"
cpx -av -- "$KDE_CONF_D/plasma/kwinrc"               "$CONFIGD/kwinrc"

# ---- APPLICATIONS
# Konsole profiles
if [ -d "$KDE_CONF_D/applications/konsole" ]; then
    mkdir -p "$HOME/.local/share/konsole"
    run command cp -av -- "$KDE_CONF_D/applications/konsole/"* "$HOME/.local/share/konsole/"
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
    run command cp -av -- "$KDE_CONF_D/applications/haruna/"* "$CONFIGD/haruna/"
fi

# Krita
[ -f "$KDE_CONF_D/applications/krita/kritarc" ] && \
    cpx -av -- "$KDE_CONF_D/applications/krita/kritarc" "$CONFIGD/kritarc"
[ -f "$KDE_CONF_D/applications/krita/kritashortcutsrc" ] && \
    cpx -av -- "$KDE_CONF_D/applications/krita/kritashortcutsrc" "$CONFIGD/kritashortcutsrc"



echo -e "\n${_GREEN}Installation finished!${_RESET}"

# Adjust user bash config
let_override_bashrc=""
prompt "Let override user bash config(~/.bashrc)? [y/N] " let_override_bashrc
[[ "$let_override_bashrc" =~ $validator_regex ]] && \
    run command cp -av -- "./MISC/.bashrc" "$HOME/.bashrc"

postinstall_exec=""
prompt "Run postinstall? [y/N] " postinstall_exec
# postinstall execution
if [[ "$postinstall_exec" =~ $validator_regex ]]; then
    sudo mandb
    enable_service keyd
    enable_service man-db.timer
    fc-cache -fv # for fonts to refresh
    echo -e "${_GREEN}Optional post-install execution finished!${_RESET}\n"
fi

update_system=""
prompt "Update system? [y/N] " update_system
# update system too
if [[ "$update_system" =~ $validator_regex ]]; then
    sudo pacman -Syu
    echo -e "${_GREEN}Refreshed databases and updated system!${_RESET}"
fi


# Finish (RE-LOGIN, REBOOT, NOTHING)
echo -e "\n\n"; print_dots
echo -e "\033[0;36mYour system is ready to reflect configurations.${_RESET}\n\n"
handle_finish

