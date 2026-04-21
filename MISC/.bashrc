#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return           

# Source configs
BASH_CONFIG_DIR="${BASH_CONFIG_DIR:-$HOME/.config/bashrc.d}"
if [ -d "$BASH_CONFIG_DIR" ]; then
    for file in "$BASH_CONFIG_DIR"/*.sh; do
        [ -r "$file" ] && source "$file"
    done
    unset file
fi
