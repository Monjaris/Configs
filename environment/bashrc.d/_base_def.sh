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
alias journal='type journal; journalctl --no-pager -l'
alias jerrors='type jerrors; journalctl -p 3 -xb --pager-end'


silent () {
    bash -c "$*" >/dev/null 2>&1 || true
}

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


# === PACKAGE MANAGER HELPERS ===
new () {
	printf "${UBLUE}:: pacman${CLR0} — install new packages\n\n"
	printf "${BWHITE}:: Search${CLR0}\n"
	for pkg in "$@"; do
		pacman -Ss "$pkg"
	done
	printf "${BWHITE}:: Install${CLR0}\n"
	sudo pacman -S --needed "$@"
}
#
aunew () {
    printf "${UYELLOW}:: yay${CLR0} — install new packages from AUR\n\n"
    printf "${BWHITE}:: Install${CLR0} ${BYELLOW}%s${CLR0}\n" "$*"
    
    yay -S --needed "$@"
}
#
pacrem () {
	local pkg="$@"
	printf "${UBLUE}:: pacman${CLR0} — remove packages\n\n"
	printf "${BWHITE}:: Search${CLR0}\n"
	pacman -Qs "$pkg"
	printf "${BWHITE}:: Remove${CLR0}\n"
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


# Translate text
trl () {
    local engine="google"; local flags=""; 
    local src="en"; local dest="az"; local text=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -e)
                engine="$2"; shift 2
                ;;
            -s|-src)
                src="$2"; shift 2
                ;;
            -d|-dest)
                dest="$2"; shift 2
                ;;
            -r)
                temp=$src; src=$dest; dest=$temp; shift
                ;;
            --)
                shift; flags="$@"; break
                ;;
            *)
                text="$1"; shift
                ;;
        esac
    done
    #
    [[ -z "$text" ]] && return 1
    trans -e "$engine" "$src:$dest" "$text" "$flags"
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

    if ! command -v yay &>/dev/null; then
        echo "⚠️  yay not found" >&2
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
        yay -Si "$pkg_or_cmd"
    fi
}


cf () {
    local help_text="Usage: cf [subcommand|flags]
    Subcommands: bash, keyd, aur, ed, term, code, zed, ff, yazi, clangd
    Flags: -r, -u, -p, -i (combinable: -upi)"

    if [[ "$1" == -* ]]; then
        local do_r=0 do_u=0 do_p=0 do_i=0
        local OPTIND=1
        while getopts "rupih" opt "$@"; do
            case "$opt" in
                r) do_r=1 ;;
                u) do_u=1 ;;
                p) do_p=1 ;;
                i) do_i=1 ;;
                h) echo help_text; return ;;
                ?)
                    echo "Unknown flag: -$OPTARG" >&2
                    return 1 ;;
            esac
        done

        [[ $do_r == 1 ]] && \
            cd "$HOME/Documents/configs/" && git status
        [[ $do_u == 1 ]] && \
            { echo "Updating configurations..."; "$HOME/Documents/configs/update.sh"; }
        [[ $do_p == 1 ]] && \
            { echo "Pushing to the repo..."; cd "$HOME/Documents/configs/"; ./push.sh; cd -; }
        [[ $do_i == 1 ]] && \
            { echo "Installing configurations..."; "$HOME/Documents/configs/install.sh"; }
        return
    fi

    case "$1" in
        bash)
            case "$2" in
                def)      ed "$BASH_CONFIG_DIR/_base_def.sh" ;;
                ini|init) ed "$BASH_CONFIG_DIR/_start.sh" ;;
                seq)      ed "$BASH_CONFIG_DIR/_sequences.sh" ;;
                fn|func)  ed "$BASH_CONFIG_DIR/functions.sh" ;;
                rc|.)     ed "$HOME/.bashrc" ;;
                *)        cd "$BASH_CONFIG_DIR/"; lsa ;;
            esac
            ;;
        keyd)
            cd "/etc/keyd"; lsa; sudo bat -n --paging=never "default.conf" ;;
        aur)
            cd "$HOME/.config/yay"; lsa ;;
        ed)
            cd "$HOME/.config/micro"; lsa ;;
        term)
            cd "$HOME/.config/kitty"; lsa ;;
        code)
            cd "$HOME/.config/Code/User"; lsa ;;
        zed)
            cd "$HOME/.config/zed"; lsa ;;
        ff)
            cd "$HOME/.config/fastfetch"; lsa; bat "config.jsonc" ;;
        yazi)
            cd "$HOME/.config/yazi"; lsa; bat "yazi.toml" ;;
        clangd)
            cd "$HOME/.config/clangd"; lsa; bat "config.yaml" ;;
        --help)
            echo help_text ;;
        *)
            cd "$HOME/.config" && lsa ;;
    esac
}

