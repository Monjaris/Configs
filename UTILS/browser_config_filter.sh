#!/bin/bash

BRAVE_PREFS="$HOME/.config/BraveSoftware/Brave-Browser/Default/Preferences"
REPO_PREFS="$(dirname "$0")/../brave/Default/Preferences"

_filter='
{
    brave:  { accelerators: .brave.accelerators },
    browser: {
        custom_chrome_frame: .browser.custom_chrome_frame,
        theme:               .browser.theme
    },
    default_search_provider_data: .default_search_provider_data,
    devtools: { preferences: .devtools.preferences },
    extensions: { settings: .extensions.settings },
    privacy_sandbox: .privacy_sandbox,
    profile: {
        avatar_index: .profile.avatar_index,
        name:         .profile.name
    },
    savefile: .savefile,
    webkit:  .webkit
}
'

if [[ "$1" == "update" ]]; then
    mkdir -p "$(dirname "$REPO_PREFS")"
    jq "$_filter" "$BRAVE_PREFS" > "$REPO_PREFS"
    echo "Browser config saved to repo."

elif [[ "$1" == "install" ]]; then
    if pgrep -x "brave" &>/dev/null; then
        echo "Brave is running! Close it before installing preferences."
        exit 1
    fi
    mkdir -p "$(dirname "$BRAVE_PREFS")"
    jq "$_filter" "$REPO_PREFS" > "$BRAVE_PREFS"
    echo "Browser config installed."

else
    echo "This script must have argument passed at position 1!"
    echo "Arguments: update, install"
    echo "Exiting."; exit 1
fi
