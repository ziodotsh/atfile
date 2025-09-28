#!/usr/bin/env bash

function atfile.install() {
    override_path="$1"
    override_version="$2"
    override_did="$3"

    # shellcheck disable=SC2154
    [[ $_output_json == 1 ]] && atfile.die "Command not available as JSON"
    
    uid="$(id -u)"
    # shellcheck disable=SC2154
    conf_dir="${_path_envvar%/*}"
    install_file="atfile"
    unset found_version
    unset install_dir
    unset source_did

    atfile.util.check_prog "curl"
    atfile.util.check_prog "jq"

    # shellcheck disable=SC2154
    if [[ $_os_supported == 0 ]]; then
        atfile.die "Unsupported OS (${_os//unknown-/})"
    fi

    case $_os in
        "linux-termux")
            # NOTE: The correct path would be '$PREFIX/local/bin would be more correct,
            #       however, '$PREFIX/local' doesn't exist by default on Termux (and thus,
            #       not in $PATH), so we'll install it in '$PREFIX/bin' instead
            install_dir="$PREFIX/bin"
            ;;
        "haiku")
            install_dir="/boot/system/non-packaged/bin"
            ;;
        *)
            if [[ $uid == 0 ]]; then
                install_dir="/usr/local/bin"
            else
                # shellcheck disable=SC2154
                install_dir="$_path_home/.local/bin"
            fi
            ;;
    esac

    if [[ $# -gt 0 ]]; then
        atfile.say.debug "Overridden variables\n↳ Path: $override_path\n↳ Version: $override_version\n↳ DID: $override_did"
    fi

    atfile.say.debug "Setting up..."

    [[ -n "$override_path" ]] && install_dir="$override_path"
    mkdir -p "$install_dir"
    mkdir -p "$conf_dir"
    # shellcheck disable=SC2154
    touch "$conf_dir/$_file_envvar"

    if [[ -f "$install_dir/$install_file" ]]; then
        atfile.die "Already installed ($install_dir/$install_file)"
    fi

    atfile.say.debug "Resolving latest version..."

    # shellcheck disable=SC2154
    if [[ -z "$override_did" ]]; then
        if [[ $_meta_did == "{:"*":}" ]]; then
            # shellcheck disable=SC2154
            source_did="$(atfile.util.get_envvar "${_envvar_prefix}_FORCE_META_DID")"
        else
            source_did="$_meta_did"
        fi
    else
        source_did="$override_did"
    fi

    atfile.util.override_actor "$source_did"
    # BUG: $_fmt_blob_url_default is unpopulated
    _fmt_blob_url="[server]/xrpc/com.atproto.sync.getBlob?did=[did]&cid=[cid]"

    if [[ -z "$override_version" ]]; then
        latest_version_record="$(com.atproto.repo.getRecord "$source_did" "self.atfile.latest" "self")"
        error="$(atfile.util.get_xrpc_error $? "$latest_version_record")"
        [[ -n "$error" ]] && atfile.die "Unable to fetch latest version"

        found_version="$(echo "$latest_version_record" | jq -r '.value.version')"
    else
        found_version="$override_version"
    fi

    parsed_found_version="$(atfile.util.parse_version "$found_version")"

    found_version_key="atfile-$parsed_found_version"
    found_version_record="$(com.atproto.repo.getRecord "$source_did" "blue.zio.atfile.upload" "$found_version_key")"
    error="$(atfile.util.get_xrpc_error $? "$found_version_record")"
    [[ -n "$error" ]] && atfile.die "Unable to fetch record for '$found_version'"

    found_version_blob="$(echo "$found_version_record" | jq -r ".value.blob.ref.\"\$link\"")"
    # shellcheck disable=SC2154
    blob_url="$(atfile.util.build_blob_uri "$source_did" "$found_version_blob" "$_server")"

    atfile.say.debug "Found latest version\n↳ Version: $found_version ($parsed_found_version)\n↳ Source: $source_did\n↳ Blob: $found_version_blob"

    atfile.say.debug "Downloading...\n↳ Source: $blob_url\n↳ Dest.:  ${install_dir}/$install_file"

    curl -s -o "${install_dir}/$install_file" "$blob_url"
    # shellcheck disable=SC2181
    [[ $? != 0 ]] && atfile.die "Unable to download"

    atfile.say.debug "Installing...\n↳ OS: $_os\n↳ Install: $install_dir/$install_file\n↳ Config: $conf_dir/$_file_envvar"

    chmod +x "${install_dir}/$install_file"
    [[ $? != 0 ]] && atfile.die "Unable to set as executable"

    if [[ ! -f "$conf_dir/$_file_envvar" ]] || [[ ! -s "$conf_dir/$_file_envvar" ]]; then
        atfile.say.debug "Creating config file..."
    
        echo -e "ATFILE_USERNAME=<your-username>\nATFILE_PASSWORD=<your-password>" > "$conf_dir/$_file_envvar"
        [[ $? != 0 ]] && die "Unable to create config file ($conf_dir/$_file_envvar)"
    fi

    atfile.say "😎 Installed ATFile"
    atfile.say "   ↳ Version: $found_version"
    atfile.say "   ↳ Paths"
    atfile.say "    ↳ Install: $install_dir/$install_file"
    atfile.say "    ↳ Config:  $conf_dir/$_file_envvar"
    atfile.say "   ↳ Source: atfile://$source_did/$found_version_key"
    atfile.say "   ---"
    atfile.say "   Before running, set your credentials in the config file!"
    atfile.say "   Run '$install_file help' to get started"
    #           ------------------------------------------------------------------------------

    atfile.util.override_actor_reset
}
