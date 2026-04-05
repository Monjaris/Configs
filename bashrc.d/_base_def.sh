# Main-Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias -- -="cd -"
alias cls='printf "\033[2J\033[3J\033[1;1H"; zdo f 2 0.05'
alias ls='ls --color=auto'
alias l='eza --icons -F'
alias lsa='eza --icons -AF'
alias rm='rm -vI'
alias cp='cp -v'
alias mv='mv -iv'
alias bat='bat --set-terminal-title --no-pager --style=grid '
alias bashconf='ed $BASH_CONFIG_DIR/_base_def.sh'
alias resh="echo sourcing '.bashrc'.. && source $HOME/.bashrc"
alias mk='./build.sh'
alias term='f(){ kitty bash -ic "$*; exec bash"; }; f; unset -f f'
alias yat='systemctl sleep || systemctl suspend'
alias xxx='exit'


# Useful-Aliases
alias fuckman='echo removing pacman lock..; sudo rm /var/lib/pacman/db.lck'
alias rmorphans='sudo pacman -Rns $(pacman -Qtdq)'
alias projs="cd '$HOME/Documents/notes' && bat projs.md"
alias todos="cd '$HOME/Documents/notes' && bat todos.md"
alias py='python3'
alias zed='zeditor'
alias nano='type nano; micro'
alias qdbus='type qdbus; qdbus6'
alias seqs='type seqs; bat "$HOME/.config/bashrc.d/_sequences.sh"'
alias wget='wget -c'
alias grep='grep --color=auto'
alias ip='ip -color'
alias jerrors='type jerrors; journalctl -p 3 -xb --pager-end'
alias journal='type journal; journalctl --no-pager -l'


rmfolder () {
    local folder="$1"
    local name
    local trashinfo

    # validate arg
    if [[ -z "$folder" ]]; then
        printf "rmfolder: no argument given\n" >&2
        return 1
    fi

    if [[ ! -e "$folder" ]]; then
        printf "rmfolder: '%s': no such file or directory\n" "$folder" >&2
        return 1
    fi

    name="$(basename "$folder")"
    trashinfo="$HOME/.local/share/Trash/info/${name}.trashinfo"

    mkdir -p "$HOME/.local/share/Trash/files"
    mkdir -p "$HOME/.local/share/Trash/info"

    # write trashinfo
    printf "[Trash Info]\nPath=%s\nDeletionDate=%s\n" \
        "$(realpath "$folder")" \
        "$(date +%Y-%m-%dT%H:%M:%S)" \
        > "$trashinfo"

    mv "$folder" "$HOME/.local/share/Trash/files/"
    local code="$?"

    if [[ "$code" -ne 0 ]]; then
        rm -f "$trashinfo"  # clean up trashinfo if mv failed
        printf "rmfolder: mv failed (exit %d)\n" "$code" >&2
        return "$code"
    fi
}


new () {
	local pkg="$@"
	echo "Pacman install wrapper"
	echo ":: Search!"
	pacman -Ss "$pkg"
	sleep 1
	echo ":: Install"
	sudo pacman -S --needed "$pkg"
}

aunew () {
	tput setaf 5;
    echo " AUR package manager wrapper"
    echo "Install packages with *PARU* from aur"
    tput sgr;
    for pkg in "$@"; do
        # check if package is already installed
        if pacman -Qi "$pkg" &>/dev/null; then
        	tput setaf 4
            echo "✅ $pkg is already installed, skipping."
            tput sgr
        else
        	tput setaf 2
            echo "⬇️ Installing $pkg..."
            paru -S "$pkg"
            tput sgr
        fi
    done
}

pacrem () {
	local pkg="$@"
	echo "Pacman remove wrapper"
	echo ":: Search!"
	pacman -Qs "$pkg"
	echo ":: Remove"
	sudo pacman -Rns "$pkg"
}


# Edit files
ed () {
    local file="$1"; local temp_buffer="unsaved"
    if [ $# -eq 0 ]; then
        # 0 args: edit temporary buffer
        fresh "$temp_buffer"
        if [ -f "$temp_buffer" ]; then
            # User saved the temp buffer, prompt for filename
            echo -n "Press Enter to save as newfile_$(date +%b_%H:%M) or type filename: "
            read -r filename
            if [ -z "$filename" ]; then
                filename="newfile_$(date +%b_%H:%M)"
            fi
            mv "$temp_buffer" "$filename"
            echo -e "\033[32m✓ Saved as $filename\033[0m"
            return 0
        else
            # User didn't save
            return 1
        fi
    elif [ $# -eq 1 ]; then
        # 1 arg: edit specific file
        if [ -f "$file" ]; then
            # File exists, edit it
            fresh "$file"
            echo -e "\n$GREEN ✓ Edited $file in $EDITOR\033[0m"
            return 0
        else
            # File doesn't exist, micro will create temp buffer
            fresh "$file"
            if [ -f "$file" ]; then
                # User saved, file now exists
                echo -e "\n$MAGENTA ✓ Created $file in $EDITOR\033[0m"
                return 0
            else
                # User didn't save, file still doesn't exist
                echo -e "\n$YELLOW ✓ Temporarily edited $file and deleted\033[0m"
                return 1
            fi
        fi
    else
        echo "Usage: ed [file]"
        return 1
    fi
}


# Run command in background and exit terminal
run () {
    if [[ -z "$*" ]]; then
        echo "Usage: run <command>" >&2
        return 1
    fi
    
    bash --login -i -c "$@" &>/dev/null &
    disown
    exit
}

# Package/Command info
wtf () {
    local pkg_or_cmd="$1"
    local verbose="$2"

    if [[ -z "$pkg_or_cmd" ]]; then
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
    whatis "$pkg_or_cmd" 2>/dev/null || echo "No whatis entry for $pkg_or_cmd"
    tput sgr0

    # Print installed size
    tput setaf 5
    if pacman -Qi "$pkg_or_cmd" &>/dev/null; then
        pacman -Qi "$pkg_or_cmd" | grep "Installed Size"
    else
        echo "there is no installed package or command named $pkg_or_cmd!"
    fi
    tput sgr0

    echo ""

    # Full info if requested
    if [[ "$verbose" == "?" ]]; then
        paru -Si "$pkg_or_cmd"
    fi
}


cf () {
    case "$1" in
    	app)
    		cd "$HOME/Documents/configs" && lsa
    		printf "\n\n%sGIT STATUS:%s\n\n" "$UMAGENTA" "$CLR0"
    		git status
    		;;
        bash)
        	case "$2" in
				def)
					ed "$BASH_CONFIG_DIR/_base_def.sh"
					;;
				init)
					ed "$BASH_CONFIG_DIR/_start.sh"
					;;
				seq)
					ed "$BASH_CONFIG_DIR/_sequences.sh"
					;;
				fn|func)
					ed "$BASH_CONFIG_DIR/functions.sh"
					;;
				rc)
            		ed "$HOME/.bashrc"
            		;;
            	*)
            		cd "$BASH_CONFIG_DIR/" && lsa
            		;;
        	esac
        	;;
        ed)
            cd "$HOME/.config/micro" && lsa
            ;;
        term)
            cd "$HOME/.config/kitty" && lsa
            ;;
        code)
            cd "$HOME/.config/Code/User" && lsa
            ;;
        zed)
            cd "$HOME/.config/zed" && lsa
            ;;
        keyd)
            cd "/etc/keyd" && lsa
            sudo bat -n --paging=never "default.conf"
            ;;
        ff)
        	cd "$HOME/.config/fastfetch" && lsa
        	bat "config.jsonc"
        	;;
        yazi)
        	cd "$HOME/.config/yazi" && lsa
        	bat "yazi.toml"
        	;;
        lsp)
        	cd "$HOME/.config/clangd" && lsa
			bat "config.yaml"
        	;;

        -h|--help)
            echo "Usage: cf [option]"
            echo "Options: sh, micro, kitty, code, zed, keymap, -h/--help"
            ;;
        *)
            cd "$HOME/.config" && lsa
            ;;
    esac
}

