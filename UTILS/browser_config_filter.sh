#!/bin/bash
# =============================================================
# browser_config_filter.sh
# Generic Chromium-based browser config sync.
#
# Detects which browser to operate on, builds an appropriate
# jq filter for it, then either reads live→repo (update) or
# repo→live (install).
#
# Adding a new browser: append one entry to each B_* map and
# to BROWSER_NAMES. Nothing else changes.
# =============================================================

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_BASE="$SCRIPT_DIR/.."  # repo root; browser configs live at $REPO_BASE/<name>/Preferences

# --- Logging helpers ---
_log()  { printf '  [browser] %s\n'        "$*";      }
_warn() { printf '  [browser] !! %s\n'     "$*" >&2;  }
_die()  { printf '\033[1;31m  [browser] FATAL: %s\033[0m\n' "$*" >&2; exit 1; }

# =============================================================
# BROWSER REGISTRY
#
# B_CONFIG_SUBDIR  — path under ~/.config/ to the browser's data dir
# B_PREFS_SUB      — path *within* that dir to the Preferences file
#                    (most use Default/Preferences; Opera doesn't)
# B_PROC           — process name for pgrep
# B_HAS_ACCEL      — set to 1 if the browser stores custom keyboard
#                    shortcuts under .brave.accelerators in its prefs
#                    (currently Brave-specific; absent = 0)
# =============================================================
MODE="$1"
shift; BROWSER_NAMES=("$@")


declare -A B_CONFIG_SUBDIR=(
    [brave]="BraveSoftware/Brave-Browser"
    [brave-origin]="BraveSoftware/"Brave-Origin*
    [chrome]="google-chrome"
    [chromium]="chromium"
    [vivaldi]="vivaldi"
    [opera]="opera"
)
declare -A B_PREFS_SUB=(
    [brave]="Default/Preferences"
    [brave-origin]="Default/Preferences"
    [chrome]="Default/Preferences"
    [chromium]="Default/Preferences"
    [vivaldi]="Default/Preferences"
    [opera]="Preferences"          # Opera omits the Default/ level
)
declare -A B_PROC=(
    [brave]="brave"
    [brave-origin]="brave"
    [chrome]="google-chrome"
    [chromium]="chromium"
    [vivaldi]="vivaldi"
    [opera]="opera"
)
declare -A B_HAS_ACCEL=(
    [brave]=1
    [brave-origin]=1
    # extend here if another browser gains an equivalent field
)

# --- Path helpers ---
live_prefs_path() { echo "$HOME/.config/${B_CONFIG_SUBDIR[$MODE]}/${B_PREFS_SUB[$MODE]}"; }
repo_prefs_path() { echo "$REPO_BASE/$MODE/Preferences"; }

# =============================================================
# JQ FILTER BUILDER
#
# Constructs a filter for the given browser. Fields that don't
# exist in the source file become null and are stripped by the
# trailing with_entries guard, so we never write null keys for
# absent features.
#
# Browser-specific extras (e.g. .brave.accelerators) are only
# injected when the registry marks the browser as supporting them.
# =============================================================
build_filter() {
    local name="$MODE"
    local has_accel="${B_HAS_ACCEL[$MODE]:-0}"

    _log "Building jq filter for '$name'"
    _log "  core fields: default_search_provider_data, devtools, extensions,"
    _log "               privacy_sandbox, profile, savefile, webkit"

    local extra_field=""
    if [[ "$has_accel" == "1" ]]; then
        _log "  extra field: .brave.accelerators (browser supports this)"
        extra_field=',
  brave: { accelerators: .brave.accelerators }'
    else
        _log "  skipping .brave.accelerators (not applicable for $name)"
    fi

    # The trailing with_entries strips any key whose value resolved to null,
    # keeping the output clean for browsers that lack certain fields.
    cat <<EOF
{
  default_search_provider_data: .default_search_provider_data,
  devtools:      { preferences: .devtools.preferences },
  extensions:    { settings: .extensions.settings },
  privacy_sandbox: .privacy_sandbox,
  profile:       { avatar_index: .profile.avatar_index, name: .profile.name },
  savefile:      .savefile,
  webkit:        .webkit${extra_field}
} | with_entries(select(.value != null))
EOF
}

# =============================================================
# DETECTION — used by the update path
#
# Priority:
#   1. Running process  (most reliable: tells us exactly what's open)
#   2. Config dir exists (fallback for when the browser isn't running)
#
# The install path doesn't detect from the live system; it reads
# which browser subdirs exist in the repo instead.
# =============================================================
detect_for_update() {
    _log "Detecting browser to update from..."

    _log "  step 1: looking for a running Chromium browser process"
    for name in "${BROWSER_NAMES[@]}"; do
        if pgrep -x "${B_PROC[$name]}" &>/dev/null; then
            _log "  -> running process found: $name (${B_PROC[$name]})"
            echo "$name"; return 0
        fi
    done

    _log "  step 2: no running browser — scanning for existing config dirs"
    for name in "${BROWSER_NAMES[@]}"; do
        local p; p=$(live_prefs_path "$name")
        if [[ -f "$p" ]]; then
            _log "  -> config dir found: $name"
            _log "     $p"
            echo "$name"; return 0
        fi
    done

    return 1
}

# =============================================================
# UPDATE  (live system → repo)
# =============================================================
do_update() {
    _log "Mode: update (live -> repo)"

    local name; name=$(detect_for_update) \
        || _die "No Chromium-based browser found. Nothing to update."

    local live; live=$(live_prefs_path "$name")
    local repo; repo=$(repo_prefs_path "$name")
    local filter; filter=$(build_filter "$name")

    if [[ ! -f "$live" ]]; then
        _warn "Live prefs file does not exist: $live"
        _warn "Skipping browser config update."
        return 0
    fi

    _log "Source : $live"
    _log "Dest   : $repo"
    _log "Filtering and writing..."

    mkdir -p "$(dirname "$repo")"
    jq -c "$filter" "$live" > "$repo"
    _log "Done — browser prefs saved to repo."
}

# =============================================================
# INSTALL  (repo → live system)
#
# Iterates every browser we know about. For each one:
#   - skip if no repo file exists (browser never configured here)
#   - skip with warning if browser is currently running
#     (Chromium overwrites Preferences on exit, so we must install
#      only when the browser is closed)
#   - otherwise write filtered prefs to the live path
# =============================================================
do_install() {
    _log "Mode: install (repo -> live)"
    _log "Scanning repo for known browser configs..."

    local installed=0

    for name in "${BROWSER_NAMES[@]}"; do
        local repo; repo=$(repo_prefs_path "$name")

        if [[ ! -f "$repo" ]]; then
            _log "  $name: no repo config found, skipping"
            continue
        fi

        _log "  $name: repo config found at $repo"

        local proc="${B_PROC[$name]}"
        if pgrep -x "$proc" &>/dev/null; then
            _warn "  $name: browser is currently running (process: $proc)"
            _warn "         close it and re-run install to apply its config"
            continue
        fi

        local live; live=$(live_prefs_path "$name")
        local filter; filter=$(build_filter "$name")

        _log "  $name: installing -> $live"
        mkdir -p "$(dirname "$live")"
        jq -c "$filter" "$repo" > "$live"
        _log "  $name: installed."
        (( installed++ ))
    done

    if [[ "$installed" -eq 0 ]]; then
        _warn "No browser configs were installed (all skipped or already running)."
    else
        _log "Done — $installed browser config(s) installed."
    fi
}

# =============================================================
# ENTRY POINT
# =============================================================
case "$MODE" in
    update)  do_update  ;;
    install) do_install ;;
    *) _die "Usage: $0 <update|install>" ;;
esac
