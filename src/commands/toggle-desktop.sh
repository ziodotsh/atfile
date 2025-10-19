#!/usr/bin/env bash

function atfile.toggle_desktop() {
    unset desktop_dir
    unset mime_dir

    # shellcheck disable=SC2154
    [[ $_os == "haiku" ]] && atfile.die "Not available on Haiku"
    [[ $_os == "macos" ]] && atfile.die "Not available on macOS"

    uid="$(id -u)"
    if [[ $uid == 0 ]]; then
        desktop_dir="/usr/local/share/applications"
        mime_dir="/usr/local/share/mime"
    else
        desktop_dir="$HOME/.local/share/applications"
        mime_dir="$HOME/.local/share/mime"
    fi

    desktop_path="$desktop_dir/atfile-handler.desktop"
    mkdir -p "$desktop_dir"
    mkdir -p "$mime_dir"

    if [[ -f "$desktop_path" ]]; then
        atfile.say "Removing '$desktop_path'..."
        rm "$desktop_path"
    else
        atfile.say "Installing '$desktop_path'..."

        echo "[Desktop Entry]
Name=ATFile (Handler)
Description=Handle atfile:/at: URIs with ATFile
Exec=$_prog_path handle %U
Terminal=false
Type=Application
MimeType=x-scheme-handler/at;x-scheme-handler/atfile;
NoDisplay=true" > "$desktop_path"
    fi

    if [ -x "$(command -v xdg-mime)" ] &&\
        [ -x "$(command -v update-mime-database)" ]; then
        atfile.say "Updating mime database..."

        update-mime-database "$mime_dir"
        xdg-mime default atfile-handler.desktop x-scheme-handler/at
        xdg-mime default atfile-handler.desktop x-scheme-handler/atfile
    fi
}
