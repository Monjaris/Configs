what? () {
    local color="167"
    local image="eyes"

    case "$1" in
        c)
            color="$2"
            ;;
        i)
            image="$2"
            ;;
        -r)
            color="$(( RANDOM % 255 + 1 ))"
            ;;
        -R)
            if ! command -v cowsay &>/dev/null; then
                echo "⚠️  cowsay not found" >&2
                return 1
            fi
            image="$(cowsay -l | tail -n +2 | tr ' ' '\n' | shuf -n1)"
            ;;
        -rR|-Rr)
            color="$(( RANDOM % 255 + 1 ))"
            if command -v cowsay &>/dev/null; then
                image="$(cowsay -l | tail -n +2 | tr ' ' '\n' | shuf -n1)"
            fi
            ;;
    esac

    if ! command -v fortune &>/dev/null || ! command -v cowsay &>/dev/null; then
        echo "⚠️  Requires fortune and cowsay" >&2
        return 1
    fi

    tput setaf "$color"
    fortune | cowsay -f "$image"
    tput sgr0
}


cf () {
    case "$1" in
        sh)
            ed "$HOME/.bashrc"
            ;;
        micro)
            cd "$HOME/.config/micro" && lsa
            ;;
        kitty)
            cd "$HOME/.config/kitty" && lsa
            ;;
        code)
            cd "$HOME/.config/Code/User" && lsa
            ;;
        zed)
            cd "$HOME/.config/zed" && lsa
            ;;
        keymap)
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


zdo () {
    case "$1" in
        f)
            if [[ -z "$2" ]]; then
                tput flash
            else
                tput smcup
                local clr="${2:-1}"
                tput setab "$clr"
                local dur="${3:-0.075}"
                tput clear
                sleep "$dur"
                tput rmcup
            fi
            ;;
        
        ff)
            clear
            zdo f 5
            command -v fastfetch &>/dev/null && fastfetch || echo "⚠️  fastfetch not found"
            ;;
        
        ff0)
            clear
            zdo f 5
            if command -v fastfetch &>/dev/null; then
                fastfetch --config ~/.config/fastfetch/empty.jsonc
            else
                echo "⚠️  fastfetch not found"
            fi
            ;;
        
        e)
            micro "$2"
            ;;
        
        t)
            shift
            if [[ -z "$*" ]]; then
                echo "Usage: zdo t <command>" >&2
                return 1
            fi
            
            zdo f 1 0.025
            local start=$(date +%s.%N)
            "$@"
            local end=$(date +%s.%N)
            zdo f 2 0.025
            
            local duration=$(awk "BEGIN {printf \"%.3f\", $end - $start}")
            tput setaf 2
            printf "\nTime: %s seconds\n" "$duration"
            tput sgr0
            ;;
        
        put)
            if ! command -v figlet &>/dev/null; then
                echo "⚠️  figlet not found" >&2
                return 1
            fi
            tput setaf 11
            figlet -c -t -k "$2"
            tput sgr0
            ;;
        
        cm)
            command -v cmatrix &>/dev/null && cmatrix || echo "⚠️  cmatrix not found"
            ;;
        
        aq)
            command -v asciiquarium &>/dev/null && asciiquarium || echo "⚠️  asciiquarium not found"
            ;;
        
        bp)
            tput setaf 5
            acpi -b 2>/dev/null || echo "⚠️  acpi not found or no battery"
            tput sgr0
            ;;
        
        i)
            ihav
            ;;
        
        rd)
            local max="${2:-100}"
            echo $(( $(od -An -N4 -tu4 < /dev/urandom | tr -d ' ') % (max + 1) ))
            ;;
        
        r)
            printf "\n\n"
            tput setaf 5
            awk '/MemTotal/ {total=$2} /MemAvailable/ {avail=$2} END {
                used = total - avail;
                printf "Usage: %.1f%%\n", used / total * 100;
            }' /proc/meminfo
            tput setaf 6
            echo
            awk '/MemTotal/ {total=$2} /MemAvailable/ {avail=$2} END {
                used = total - avail;
                printf "Used: %.2f GB\n", used / 1024 / 1024;
                printf "Available: %.2f GB\n", avail / 1024 / 1024;
                printf "Total: %.2f GB\n", total / 1024 / 1024;
            }' /proc/meminfo
            tput sgr0
            ;;

        keymap)
            tput setaf 3
            echo "Editing: ~/.config/xremap/config.yml"
            tput sgr0
            echo -e "\n\n"
            systemctl --user restart xremap.service
            systemctl --user status xremap.service
            ;;

        sd)
            local secs="${2:-3}"
            printf "Shutting down in %s seconds (Ctrl+C to cancel)...\n" "$secs"
            sleep "$secs"
            for i in 3 2 1; do
                echo "$i"
                sleep 1
            done
            sudo shutdown -h now
            exit
            ;;
        
        dlm)
            local url="$2"
            local start="$3"
            local end="$4"
            
            if [[ -z "$url" ]]; then
                echo "Usage:"
                echo "  zdo dlm <url>              - download full audio"
                echo "  zdo dlm <url> <duration>   - first N seconds"
                echo "  zdo dlm <url> <start> <end> - segment from start to end"
                return 1
            fi
            
            if ! command -v yt-dlp &>/dev/null; then
                echo "⚠️  yt-dlp not found" >&2
                return 1
            fi
            
            if [[ -z "$start" ]]; then
                yt-dlp -x --audio-format vorbis \
                    -o "$HOME/Music/all/%(title)s.%(ext)s" "$url"
            elif [[ -z "$end" ]]; then
                yt-dlp -x --audio-format vorbis \
                    --postprocessor-args "-t $start" \
                    -o "$HOME/Music/all/%(title)s.%(ext)s" "$url"
            else
                local duration=$((end - start))
                yt-dlp -x --audio-format vorbis \
                    --postprocessor-args "-ss $start -t $duration" \
                    -o "$HOME/Music/all/%(title)s.%(ext)s" "$url"
            fi
            ;;

        *)
            echo "Usage: zdo <command>"
            echo "Commands: f, ff, ff0, e, t, put, cm, aq, bp, i, rd, r, keymap, sd, dlm"
            ;;
    esac
}


ihav() {
    tput sgr0
    tput setaf 6
    printf "\n          +-----------------------------+\n"
    printf "          |       ~%s has...        |\n" "$USER"
    printf "          +-----------------------------+\n\n"
    tput sgr0
    
    if [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
        local bat=$(cat /sys/class/power_supply/BAT0/capacity)
        local bat_status=$(cat /sys/class/power_supply/BAT0/status)
        tput setaf 5
        printf "\n\n  🔋 Battery:   "
        if [[ $bat -le 20 ]]; then
            tput setaf 1
        elif [[ $bat -le 50 ]]; then
            tput setaf 3
        else
            tput setaf 2
        fi
        printf "%3s%%" "$bat"
        tput setaf 8
        printf "  (%s)\n" "$bat_status"
        tput sgr0
    fi
    
    local ram_info=$(free | grep Mem)
    local ram_used=$(echo $ram_info | awk '{print $3}')
    local ram_total=$(echo $ram_info | awk '{print $2}')
    local ram_percent=$(echo $ram_info | awk '{printf "%.1f", $3/$2*100}')
    local ram_used_gb=$(LC_NUMERIC=C awk "BEGIN {printf \"%.1f\", $ram_used/1024/1024}")
    local ram_total_gb=$(LC_NUMERIC=C awk "BEGIN {printf \"%.1f\", $ram_total/1024/1024}")
    
    tput setaf 5
    printf "  🧠 RAM:       "
    if (( $(echo "$ram_percent > 80" | bc -l) )); then
        tput setaf 1
    elif (( $(echo "$ram_percent > 60" | bc -l) )); then
        tput setaf 3
    else
        tput setaf 2
    fi
    printf "%5s%%" "$ram_percent"
    tput setaf 8
    printf "  (%sG / %sG)\n" "$ram_used_gb" "$ram_total_gb"
    tput sgr0
    
    local disk_info=$(df -h / | awk 'NR==2 {print $5, $3, $2}')
    local disk_percent=$(echo $disk_info | awk '{print $1}' | sed 's/%//')
    local disk_used=$(echo $disk_info | awk '{print $2}')
    local disk_total=$(echo $disk_info | awk '{print $3}')
    
    tput setaf 5
    printf "  💾 Storage:   "
    if [[ $disk_percent -gt 80 ]]; then
        tput setaf 1
    elif [[ $disk_percent -gt 60 ]]; then
        tput setaf 3
    else
        tput setaf 2
    fi
    printf "%5s%%" "$disk_percent"
    tput setaf 8
    printf "  (%s / %s)\n" "$disk_used" "$disk_total"
    tput sgr0

    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.1f", 100-$8}')
    tput setaf 5
    printf "  ⚡ CPU:       "
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        tput setaf 1
    elif (( $(echo "$cpu_usage > 60" | bc -l) )); then
        tput setaf 3
    else
        tput setaf 2
    fi
    printf "%5s%%\n" "$cpu_usage"
    tput sgr0
    
    tput setaf 8
    printf "\n\nThird Party Tools:\n"
    tput setaf 6
    printf "fastfetch, tput, xdotool, htop\n"
    printf "cmatrix, btop, asciiquarium, figlet\n"
    printf "\n\n\n"
    tput sgr0
    
    tput setaf 4
    printf "  +-- Aliases ---------------------+\n"
    tput setaf 3
    printf "  |  %-8s" "cls"
    tput sgr0
    printf " -> clear screen         |\n"
    tput setaf 3
    printf "  |  %-8s" "lsa"
    tput sgr0
    printf " -> eza listing          |\n"
    tput setaf 4
    printf "  +--------------------------------+\n\n"
    tput sgr0
    
    tput setaf 4
    printf "  +-- Functions -------------------+\n"
    tput sgr0
    tput setaf 2
    printf "  |  %-18s" "ihav()"
    tput sgr0
    printf " -> this command |\n"
    tput setaf 2
    printf "  |  %-18s" "term()"
    tput sgr0
    printf " -> new terminal |\n"
    tput setaf 2
    printf "  |  %-18s" "zdo()"
    tput sgr0
    printf " -> utilities    |\n"
    tput setaf 2
    printf "  |  %-18s" "cxx()"
    tput sgr0
    printf " -> g++ wrapper  |\n"
    tput setaf 2
    printf "  |  %-18s" "what?()"
    tput sgr0
    printf " -> fortune/cow  |\n"
    tput setaf 4
    printf "  +--------------------------------+\n\n"
    tput sgr0
}


cxx() {
    local run_after=false
    local use_bin_folder=false
    local custom_output=""
    local debug_mode=false
    local optimization="-O0"
    local OPTIND=1

    while getopts "rbo:dp" opt; do
        case $opt in
            r) run_after=true ;;
            b) use_bin_folder=true ;;
            o) custom_output="$OPTARG" ;;
            d) debug_mode=true ;;
            p) optimization="-O3" ;;
            \?)
                echo "Usage: cxx [-r] [-b] [-o output] [-d] [-p] <source_file> [linking_flags...]"
                echo "  -r: run after compilation"
                echo "  -b: place output in bin/ folder"
                echo "  -o: custom output name"
                echo "  -d: debug mode (adds -g flag)"
                echo "  -p: performance mode (-O3 instead of -O0)"
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    if [[ $# -lt 1 ]]; then
        echo "Usage: cxx [-r] [-b] [-o output] [-d] [-p] <source_file> [linking_flags...]"
        return 1
    fi

    local source_file="$1"

    if [[ ! -f "$source_file" ]]; then
        echo "Error: Source file '$source_file' not found" >&2
        return 1
    fi

    shift

    local output_name
    if [[ -n "$custom_output" ]]; then
        output_name="$custom_output"
    else
        local filename=$(basename "$source_file")
        output_name="${filename%.*}"
    fi

    if [[ "$use_bin_folder" == true ]]; then
        if [[ ! -d "bin" ]]; then
            mkdir -p bin
            echo "Created bin/ directory"
        fi
        output_name="bin/$output_name"
    fi

    local compile_cmd="g++ -std=c++23 $optimization"

    if [[ "$debug_mode" == true ]]; then
        compile_cmd="$compile_cmd -g"
    fi

    compile_cmd="$compile_cmd \"$source_file\" $* -o \"$output_name\""

    echo "Compiling: $source_file -> $output_name"
    eval "$compile_cmd"

    local compile_status=$?
    if [[ $compile_status -ne 0 ]]; then
        echo "❌ Compilation failed" >&2
        return $compile_status
    fi

    echo "✅ Compilation successful"

    if [[ "$run_after" == true ]]; then
        echo "Running: $output_name"
        echo "─────────────────────────────────"
        "./$output_name"
    fi
}


sin() {
    if ! command -v python3 &>/dev/null; then
        echo "⚠️  python3 not found" >&2
        return 1
    fi
    python3 -c "import math; print(math.sin(math.radians($1)))"
}

cos() {
    python3 -c "import math; print(math.cos(math.radians($1)))"
}

tan() {
    python3 -c "import math; print(math.tan(math.radians($1)))"
}

cot() {
    python3 -c "import math; print(1.0/math.tan(math.radians($1)))"
}

asin() {
    python3 -c "import math; print(math.degrees(math.asin($1)))"
}

acos() {
    python3 -c "import math; print(math.degrees(math.acos($1)))"
}

atan() {
    python3 -c "import math; print(math.degrees(math.atan($1)))"
}

atan2() {
    python3 -c "import math; print(math.degrees(math.atan2($1, $2)))"
}


sin0()  { echo "0"; }
sin30() { echo "1/2"; }
sin37() { echo "~3/5"; }
sin45() { echo "√2/2"; }
sin53() { echo "~4/5"; }
sin60() { echo "√3/2"; }
sin90() { echo "1"; }

cos0()  { echo "1"; }
cos30() { echo "√3/2"; }
cos37() { echo "~4/5"; }
cos45() { echo "√2/2"; }
cos53() { echo "~3/5"; }
cos60() { echo "1/2"; }
cos90() { echo "0"; }

tan0()  { echo "0"; }
tan30() { echo "1/√3"; }
tan37() { echo "~3/4"; }
tan45() { echo "1"; }
tan53() { echo "~4/3"; }
tan60() { echo "√3"; }
tan90() { echo "undefined"; }

cot0()  { echo "undefined"; }
cot30() { echo "√3"; }
cot37() { echo "~4/3"; }
cot45() { echo "1"; }
cot53() { echo "~3/4"; }
cot60() { echo "1/√3"; }
cot90() { echo "0"; }
