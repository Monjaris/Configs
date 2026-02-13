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
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups  # Ignore duplicates and lines starting with space
export HISTTIMEFORMAT="%F %T "  # Add timestamps to history
shopt -s histappend  # Append to history file, don't overwrite


# ============================================
# Shell Options
# ============================================
shopt -s checkwinsize  # Update LINES and COLUMNS after each command
shopt -s cdspell       # Autocorrect minor spelling errors in cd
shopt -s dirspell      # Autocorrect directory names during tab completion
shopt -s globstar      # Enable ** for recursive globbing
shopt -s autocd        # cd by just typing directory name (bash 4+)
shopt -s dotglob       # Include hidden files in glob matches (optional)


# ============================================
# Prompt Configuration
# ============================================
PS_IDK='\n\[\e[1;32m\]$HOME/\[\e[0m\]\[\e[1;35m\]$(p=${PWD#$HOME}; echo "${p#/}")\[\e[0m\]\n\[\e[1;90m\]╰─➤\[\e[0m\] \[\e[1;36m\]$\[\e[0m\] '
PS_ALT='\n\[\e[1;95m\]$(if [[ $PWD == $HOME* ]]; then printf "%s/" "$HOME"; else printf "%s" "$PWD"; fi)\[\e[0m\]\[\e[1;32m\]$(if [[ $PWD == $HOME* ]]; then p="${PWD#$HOME}"; p="${p#/}"; printf "%s" "$p"; fi)\[\e[0m\]\n\[\e[1;90m\]╰─➤\[\e[0m\] \[\e[1;36m\]$\[\e[0m\] '
PS_MAIN='\n \[\e[1;32m\]$(if [[ $PWD == $HOME* ]]; then printf "%s/" "$HOME"; else printf "%s" "$PWD"; fi)\[\e[0m\]\[\e[1;35m\]$(if [[ $PWD == $HOME* ]]; then p="${PWD#$HOME}"; p="${p#/}"; printf "%s" "$p"; fi)\[\e[0m\]\n\[\e[1;90m\] ╰─➤\[\e[0m\] \[\e[1;34m\]$\[\e[0m\] '
export PS1="$PS_MAIN"


# ============================================
# Environment Variables
# ============================================
export VISUAL=micro
export EDITOR=micro


# ============================================
# Tool Integrations
# ============================================
# zoxide
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init bash)"
fi
# fzf
if command -v fzf &> /dev/null; then
    eval "$(fzf --bash)" 2>/dev/null || true
fi
# direnv
if command -v direnv &> /dev/null; then
    eval "$(direnv hook bash)"
fi

