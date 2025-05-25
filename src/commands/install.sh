#!/usr/bin/env bash

function atfile.install() {
    override_path="$1"
    override_version="$2"
    
    uid="$(id -u)"
    conf_file="atfile.env"
    install_file="atfile"
    unset conf_dir
    unset install_dir

    atfile.util.check_prog "curl"
    atfile.util.check_prog "jq"

    if [[ $_os_supported == 0 ]]; then
        atfile.die "Unsupported OS (${_os//unknown-/})"
    fi

    if [[ $_os == "haiku" ]]; then
        install_dir="/boot/system/non-packaged/bin"
        conf_dir="$HOME/config/settings"
    else
        if [[ $uid == 0 ]]; then
            install_dir="/usr/local/bin"

            if [[ -z $SUDO_DIR ]]; then
                conf_dir="/root/.config"
            else
                if [[ $_os == "macos" ]]; then
                    conf_dir="$(eval echo ~"$SUDO_USER")/Library/Application Support"
                else
                    conf_dir="$(eval echo ~"$SUDO_USER")/.config"
                fi
            fi
        else
            install_dir="$(eval echo ~"$USER")/.local/bin"
            conf_dir="$(eval echo ~"$USER")/.config"

            if [[ $_os == "macos" ]]; then
                conf_dir="$(eval echo ~"$USER")/Library/Application Support"
            else
                conf_dir="$(eval echo ~"$USER")/.config"
            fi
        fi

        # INVESTIGATE: What happens during `sudo`?
        if [[ -n "$XDG_CONFIG_HOME" ]]; then
            conf_dir="$XDG_CONFIG_HOME"
        fi
    fi

    [[ -n "$override_path" ]] && install_dir="$override_path"

    atfile.say.debug "Installing...\n↳ OS: $_os\n↳ Install: $install_dir/$install_file\n↳ Config: $conf_dir/$conf_file"

    if [[ -f "$install_dir/$install_file" ]]; then
        atfile.die "Already installed ($install_dir/$install_file)"
    fi
}
