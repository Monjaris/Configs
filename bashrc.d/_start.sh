BASH_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BASH_CONFIG_DIR

# ============================================
# PATH Configuration
# ============================================
add_to_path() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
        export PATH="$1:$PATH"
    fi
}
add_to_path "$HOME/bin"
add_to_path "$HOME/dev/c++/projs/bin"


# ============================================
# History Configuration
# ============================================
export HISTSIZE=5000
export HISTFILESIZE=25000
export HISTCONTROL=
export HISTTIMEFORMAT="%F %T "  # Add timestamps to history
shopt -s histappend  # Append to history file, don't overwrite


# ============================================
# Shell Options
# ============================================
shopt -s cdspell       # Autocorrect minor spelling errors in cd
shopt -s dirspell      # Autocorrect directory names during tab completion
shopt -s globstar      # Enable ** for recursive globbing
shopt -s autocd        # cd by just typing directory name (bash 4+)
shopt -s dotglob       # Include hidden files in glob matches (optional)
# shopt -s checkwinsize  # Update LINES and COLUMNS after each command


# ============================================
# Prompt Configuration
# ============================================
PS_MIN="\n> "
PS_SIMPLE="\n$BGREEN\w\n>$CLR0 "
PS_NORMAL='\n \[\e[1;32m\]$(if [[ $PWD == $HOME* ]]; then printf "%s/" "$HOME"; else printf "%s" "$PWD"; fi)\[\e[0m\]\[\e[1;35m\] \
$(if [[ $PWD == $HOME* ]]; then p="${PWD#$HOME}"; p="${p#/}"; printf "%s" "$p"; fi)\[\e[0m\]\n\[\e[1;90m\] ╰─➤\[\e[0m\] \[\e[1;34m\]$\[\e[0m\] '

PS_MAIN_TOP='\n \[\e[1;32m\]$(if [[ $PWD == $HOME* ]]; then printf "%s/" "$HOME"; else printf "%s" "$PWD"; fi\
)\[\e[0m\]\[\e[1;35m\]$(if [[ $PWD == $HOME* ]]; then p="${PWD#$HOME}"; p="${p#/}"; printf "%s" "$p"; fi)\[\e[0m\]'
PS_MAIN_BOT='\n\[\e[1;97m\] ╰─➤\[\e[0m\] \[\e[1;4;94m\]$\[\e[0m\] '

_ps1_status() {
    if [[ $1 -eq 0 ]]; then
        printf "\001\e[32m\002(✓)\001\e[0m\002"
    else
        printf "\001\e[31m\002[✗]\001\e[0m\002"
    fi
}

PROMPT_COMMAND='PS1="$PS_MAIN_TOP $UBLUE-> $(_ps1_status $?)$PS_MAIN_BOT"'

# eps


# ============================================
# Environment Variables
# ============================================
export VISUAL=micro
export EDITOR=micro


# ============================================
# Tool Integrations
# ============================================
# eval "$(thefuck --alias)"

