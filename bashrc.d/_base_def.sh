# Main-Aliases
alias ..='cd ..'
alias ...='cd ../..'
alias -- -="cd -"
alias cls='printf "\033[2J\033[3J\033[1;1H"; zdo f 2 0.05'
alias ls='ls --color=auto'
alias lsa='eza --icons -AF'
alias rm='rm -vI'
alias rmfolder='rmdir -v --ignore-fail-on-non-empty'
alias cp='cp -v --dereference'
alias mv='mv -iv'
alias bat='bat --set-terminal-title --no-pager --style=grid '
alias bashconf='ed $BASH_CONFIG_DIR/_base_def.sh'
alias resh="echo sourcing '.bashrc'.. && source $HOME/.bashrc"
alias mk='./build.sh'
alias term='f(){ kitty bash -ic "$*; exec bash"; }; f; unset -f f'
alias tr='trans -b :"az" '
alias xxx='exit'


# Useful-Aliases
alias fuckman='echo removing pacman lock..; sudo rm /var/lib/pacman/db.lck'
alias rmorphs='sudo pacman -Rns $(pacman -Qtdq)'
alias projs="cd '$HOME/Documents/notes' && bat projs.md"
alias todos="cd '$HOME/Documents/notes' && bat todos.md"
alias py='python3'
alias zed='zeditor'
alias nano='type nano; micro'
alias qdbus='type qdbus; qdbus6'
alias wget='wget -c'
alias grep='grep --color=auto'
alias ip='ip -color'
alias jerrors='type jerrors; journalctl -p 3 -xb --pager-end'
alias journal='type journal; journalctl --no-pager -l'



# enhanced-prompt-style
eps () 
{ 
    unset _prompt_timer _prompt_command_ran _timing_in_progress;
    
    function _prompt_timer_start () 
    { 
        # Don't start timer if we're already timing the prompt building itself
        [[ -n "$_timing_in_progress" ]] && return
        
        # Start timer for user commands only
        [[ -n "$BASH_COMMAND" && "$BASH_COMMAND" != "_prompt_timer_start" && "$BASH_COMMAND" != "_build_prompt" ]] && { 
            _prompt_timer=$(date +%s.%N);
            _prompt_command_ran=1
        }
    };
    
    function _prompt_timer_stop () 
    { 
        local t="0.0";
        if [[ -n "$_prompt_timer" && -n "$_prompt_command_ran" ]]; then
            # Set flag to prevent DEBUG trap from interfering
            _timing_in_progress=1
            local end_time=$(date +%s.%N)
            t=$(awk "BEGIN {printf \"%.3f\", $end_time - $_prompt_timer}")
            unset _timing_in_progress
        fi
        unset _prompt_timer _prompt_command_ran;
        echo "$t"
    };
    
    trap '_prompt_timer_start' DEBUG;
    
    function _build_prompt () 
    { 
        local e=$? t=$(_prompt_timer_stop) w=$(tput cols) p="$PWD" h="" r="" v l s;
        if [[ "$p" == "$HOME"* ]]; then
            h="$HOME/";
            r="${p#$HOME}";
            r="${r#/}";
        else
            h="$p";
        fi;
        [[ $e -eq 0 ]] && local i="\[${BGREEN}\]✓\[${CLR0}\]" || local i="\[${BRED}\]✗\[${CLR0}\]";
        v=${#h};
        [[ -n "$r" ]] && v=$((v + ${#r}));
        l="${t}s";
        s=$((w - v - ${#l} - 3));
        [[ $s -lt 1 ]] && s=1;
        printf "\n\[${BGREEN}\]%s\[${CLR0}\]\[${BMAGENTA}\]%s\[${CLR0}\]%*s\[${BLUE}\]%s\[${CLR0}\] %s\n\[${UBLACK}\]╰─➤\[${CLR0}\] \[${BBLUE}\]$\[${CLR0}\] " "$h" "$r" $s "" "$l" "$i"
    };
    
    PROMPT_COMMAND='PS1="$(_build_prompt)"'
}


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


# Edit files
ed () {
    local file="$1"; local temp_buffer="unsaved"
    if [ $# -eq 0 ]; then
        # 0 args: edit temporary buffer
        micro "$temp_buffer"
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
            micro "$file"
            echo -e "\n$GREEN ✓ Edited $file in micro\033[0m"
            return 0
        else
            # File doesn't exist, micro will create temp buffer
            micro "$file"
            if [ -f "$file" ]; then
                # User saved, file now exists
                echo -e "\n$MAGENTA ✓ Created $file in micro\033[0m"
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
				funcs)
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
            sudo bat -n --paging=never default.conf
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

