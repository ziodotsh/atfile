#!/usr/bin/env bash

function atfile.install() {
    override_path="$1"
    override_version="$2"
    
    uid="$(id -u)"
    conf_dir="${_path_envvar%/*}"
    install_file="atfile"
    unset install_dir

    atfile.util.check_prog "curl"
    atfile.util.check_prog "jq"

    # shellcheck disable=SC2154
    if [[ $_os_supported == 0 ]]; then
        atfile.die "Unsupported OS (${_os//unknown-/})"
    fi

    case $_os in
        "haiku")
            install_dir="/boot/system/non-packaged/bin"
            ;;
        *)
            if [[ $uid == 0 ]]; then
                install_dir="/usr/local/bin"
            else
                install_dir="$_path_home/.local/bin"
            fi
            ;;
    esac

    [[ -n "$override_path" ]] && install_dir="$override_path"
    mkdir -p "$conf_dir"
    touch "$conf_dir/$_file_envvar"

    atfile.say.debug "Installing...\n↳ OS: $_os\n↳ Install: $install_dir/$install_file\n↳ Config: $conf_dir/$_file_envvar"

    if [[ -f "$install_dir/$install_file" ]]; then
        atfile.die "Already installed ($install_dir/$install_file)"
    fi

    atfile.say "😎 Installed ATFile"
    atfile.say "   ↳ Path:   $install_dir/$install_file"
    atfile.say "   ↳ Config: $conf_dir/$_file_envvar"
    atfile.say "   ---"
    atfile.say "   Before running, set your credentials in the config file!"
    atfile.say "   Run '$install_file help' to get started"
    #           ------------------------------------------------------------------------------
}
