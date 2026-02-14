# Main-Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias -- -="cd -"
alias cls='printf "\033[2J\033[3J\033[1;1H"; zdo f 2 0.05'
alias ls='ls --color=auto'
alias lsa='eza --icons -AF'
alias rm='rm -i'
alias rmfolder='rmdir --ignore-fail-on-non-empty'
alias cp='cp -i'
alias mv='mv -i'
alias bat='bat -n --no-pager'
alias bashconf='micro $BASH_CONFIG_DIR/base_def.sh'
alias mk='./build.sh'
alias term='f(){ kitty bash -ic "$*; exec bash"; }; f; unset -f f'
alias tr='trans -b :"az" '
alias xxx='exit'


# Useful-Aliases
alias fuckman="echo removing pacman lock..; sudo rm /var/lib/pacman/db.lck"
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'
alias todop='bat $HOME/Desktop/notes/projs.md'
alias py='python3'
alias zed='zeditor'
alias nano='type nano; micro'
alias qdbus='type qdbus; qdbus6'
alias wget='wget -c'
alias grep='grep --color=auto'
alias ip='ip -color'
alias jerrors="type jerrors; journalctl -p 3 -xb"
alias journal="type journal; journalctl --no-pager --pager-end -l"


new () {
	pkg="$1"
	echo "Custom PACMAN & PARU wrapper function!"
	echo ":: Search!"
	pacman -Ss "$pkg"
	echo ":: Install"
	sudo pacman -S --needed "$pkg"
}

aunew () {
	sfc 5;
    echo " [ ARCH-USER NEW ] "
    echo "Install packages with *PARU* from aur"
    echo -e "Installation skipped if package is up to date!\n\n"
    rfc;
    for pkg in "$@"; do
        # check if package is already installed
        if pacman -Qi "$pkg" &>/dev/null; then
        	sfc 4
            echo "✅ $pkg is already installed, skipping."
            rfc
        else
        	sfc 2
            echo "⬇️ Installing $pkg..."
            paru -S "$pkg"
            rfc
        fi
    done
}

# Run command in background and exit terminal
run() {
    if [[ -z "$*" ]]; then
        echo "Usage: run <command>" >&2
        return 1
    fi
    
    bash --login -i -c "$@" &>/dev/null &
    disown
    exit
}

# Edit files
ed() {
    local file="${1:-}"
    if [[ -z "$file" ]]; then
        echo "Usage: ed <filename>" >&2
        return 1
    fi
    command -v zdo &>/dev/null && zdo f 2 0.075
    micro "$file"
    tput setaf 2
    printf "\n✓ Edited "
    tput setaf 5
    printf "%s " "$file"
    tput setaf 2
    printf "in micro!\n"
    tput sgr0
    command -v zdo &>/dev/null && zdo f 5 0.035
}

# Command/Package info
wtf() {
    local pkg="$1"
    local verbose="$2"
    
    if [[ -z "$pkg" ]]; then
        echo "Usage: wtf <package> [?]" >&2
        echo "  Add '?' for full package info" >&2
        return 1
    fi
    
    if ! command -v paru &>/dev/null; then
        echo "⚠️  paru not found" >&2
        return 1
    fi
    
    # Print whatis info
    tput setaf 2; tput bold
    whatis "$pkg" 2>/dev/null || echo "No whatis entry for $pkg"
    tput sgr0
    
    # Print installed size
    tput setaf 5
    if pacman -Qi "$pkg" &>/dev/null; then
        pacman -Qi "$pkg" | grep "Installed Size"
    else
        echo "Not installed"
    fi
    tput sgr0
    
    echo ""
    
    # Full info if requested
    if [[ "$verbose" == "?" ]]; then
        paru -Si "$pkg"
    fi
}

