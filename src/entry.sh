#!/usr/bin/env bash

# Environment

## Early-start global variables

### Permutation

_start="$(atfile.util.get_date "" "%s")" # 1
_envvar_prefix="ATFILE" # 2
_debug="$(atfile.util.get_envvar "${_envvar_prefix}_DEBUG" "$([[ $ATFILE_DEVEL == 1 ]] && echo 1 || echo 0)")" # 3
_force_os="$(atfile.util.get_envvar "${_envvar_prefix}_FORCE_OS")" # 3

### Combination

_command="$1"
_command_args=("${@:2}")
_os="$(atfile.util.get_os)"
_os_supported=0
_is_piped=0
_is_sourced=0
_meta_author="{:meta_author:}"
_meta_did="{:meta_did:}"
_meta_repo="{:meta_repo:}"
_meta_year="{:meta_year:}"
_now="$(atfile.util.get_date)"
_version="{:version:}"

## "Hello, world!"

atfile.say.debug "Reticulating splines..."

## Paths

_path_home="$HOME"

if [[ -n "$SUDO_USER" ]]; then
    _path_home="$(eval echo "~$SUDO_USER")"
fi

_file_envvar="atfile.env"
_path_blobs_tmp="/tmp"
_path_cache="$_path_home/.cache"
_path_envvar="$_path_home/.config"

case $_os in
    "haiku")
        _path_blobs_tmp="/boot/system/cache/tmp"
        _path_cache="$_path_home/config/cache"
        _path_envvar="$_path_home/config/settings"
        ;;
    "linux-termux")
        _path_blobs_tmp="/data/data/com.termux/files/tmp"
        ;;
    "macos")
        _path_envvar="$_path_home/Library/Application Support"
        _path_blobs_tmp="/private/tmp"
        ;;
esac

if [[ -n "$XDG_CONFIG_HOME" ]]; then
    _path_envvar="$XDG_CONFIG_HOME"
fi

_path_blobs_tmp="$_path_blobs_tmp/at-blobs"
_path_cache="$_path_cache/atfile"
_path_envvar="$(atfile.util.get_envvar "${_envvar_prefix}_PATH_CONF" "$_path_envvar/$_file_envvar")" 

## OS detection

atfile.say.debug "Detected OS: $_os"

if [[ $_os != "unknown-"* ]] &&\
   [[ $_os == "bsd" ]] ||\
   [[ $_os == "haiku" ]] ||\
   [[ $_os == "linux" ]] ||\
   [[ $_os == "linux-mingw" ]] ||\
   [[ $_os == "linux-termux" ]] ||\
   [[ $_os == "macos" ]] ; then
    _os_supported=1
fi

## Pipe detection

if [ -p /dev/stdin ] ||\
   [[ "$0" == "bash" || $0 == *"/bin/bash" ]]; then
    _is_piped=1
    atfile.say.debug "Piping: $0"
fi

## Source detection

if [[ -n ${BASH_SOURCE[0]} ]]; then
    if [[ "$0" != "${BASH_SOURCE[0]}" ]]; then
        if [[ "$ATFILE_DEVEL" == 1 ]]; then
            if [[ -n "$ATFILE_DEVEL_SOURCE" ]]; then
                _is_sourced=1
                atfile.say.debug "Sourcing: $ATFILE_DEVEL_SOURCE"
            fi
        else
            _is_sourced=1
            atfile.say.debug "Sourcing: ${BASH_SOURCE[0]}"
        fi
    fi
fi

# Installation

if [[ $_is_piped == 1 ]] ||\
   [[ "$1" == "install" ]]; then
    if [[ "$1" == "install" ]]; then
        atfile.install "$2" "$3"
        install_exit="$?"
    else
        atfile.install "$1" "$2"
        install_exit="$?"
    fi

    atfile.util.print_seconds_since_start_debug
    exit $install_exit
fi

# Global variables

## Reflection

_prog="$(basename "$(atfile.util.get_realpath "$0")")"
_prog_dir="$(dirname "$(atfile.util.get_realpath "$0")")"
_prog_path="$(atfile.util.get_realpath "$0")"

## Envvars

### Fallbacks

_endpoint_appview_fallback="https://api.bsky.app"
_endpoint_jetstream_fallback="$(atfile.util.get_random_pbc_jetstream)"
_endpoint_plc_directory_fallback="https://plc.directory"
_max_list_fallback=100

### Defaults

_devel_publish_default=0
_disable_pbc_fallback_default=0
_disable_update_checking_default=0
_disable_updater_default=0
_dist_username_default="$_meta_did"
_enable_fingerprint_default=0
_enable_update_git_clobber_default=0
#_endpoint_appview_default="https://bsky.zio.blue"
_endpoint_appview_default="https://api.bsky.app"
#_endpoint_jetstream_default="wss://stream.zio.blue"
_endpoint_jetstream_default="$_endpoint_jetstream_fallback"
_endpoint_plc_directory_default="https://plc.zio.blue"
_endpoint_social_app_default="https://bsky.app"
_fmt_blob_url_default="[server]/xrpc/com.atproto.sync.getBlob?did=[did]&cid=[cid]"
_fmt_out_file_default="[key]__[name]"
_enable_fingerprint_default=0
_max_list_buffer=6
_max_list_default=$(( $(atfile.util.get_term_rows) - _max_list_buffer ))
_output_json_default=0
_skip_auth_check_default=0
_skip_copyright_warn_default=0
_skip_ni_exiftool_default=0
_skip_ni_md5sum_default=0
_skip_ni_mediainfo_default=0
_skip_unsupported_os_warn_default=0

### Set

_devel_publish="$(atfile.util.get_envvar "${_envvar_prefix}_DEVEL_PUBLISH" $_devel_publish_default)"
_disable_pbc_fallback="$(atfile.util.get_envvar "${_envvar_prefix}_DISABLE_PBC_FALLBACK" $_disable_pbc_fallback_default)"
_disable_update_checking="$(atfile.util.get_envvar "${_envvar_prefix}_DISABLE_UPDATE_CHECKING" $_disable_update_checking_default)"
_disable_updater="$(atfile.util.get_envvar "${_envvar_prefix}_DISABLE_UPDATER" $_disable_updater_default)"
_dist_password="$(atfile.util.get_envvar "${_envvar_prefix}_DIST_PASSWORD")"
_dist_username="$(atfile.util.get_envvar "${_envvar_prefix}_DIST_USERNAME" $_dist_username_default)"
_enable_fingerprint="$(atfile.util.get_envvar "${_envvar_prefix}_ENABLE_FINGERPRINT" "$_enable_fingerprint_default")"
_enable_update_git_clobber="$(atfile.util.get_envvar "${_envvar_prefix}_ENABLE_UPDATE_GIT_CLOBBER" "$_enable_update_git_clobber_default")"
_endpoint_appview="$(atfile.util.get_envvar "${_envvar_prefix}_ENDPOINT_APPVIEW" "$_endpoint_appview_default")"
_endpoint_jetstream="$(atfile.util.get_envvar "${_envvar_prefix}_ENDPOINT_JETSTREAM" "$_endpoint_jetstream_default")"
_endpoint_plc_directory="$(atfile.util.get_envvar "${_envvar_prefix}_ENDPOINT_PLC_DIRECTORY" "$_endpoint_plc_directory_default")"
_endpoint_social_app="$(atfile.util.get_envvar "${_envvar_prefix}_ENDPOINT_SOCIAL_APP" "$_endpoint_social_app_default")"
_fmt_blob_url="$(atfile.util.get_envvar "${_envvar_prefix}_FMT_BLOB_URL" "$_fmt_blob_url_default")"
_fmt_out_file="$(atfile.util.get_envvar "${_envvar_prefix}_FMT_OUT_FILE" "$_fmt_out_file_default")"
_force_meta_author="$(atfile.util.get_envvar "${_envvar_prefix}_FORCE_META_AUTHOR")"
_force_meta_did="$(atfile.util.get_envvar "${_envvar_prefix}_FORCE_META_DID")"
_force_meta_repo="$(atfile.util.get_envvar "${_envvar_prefix}_FORCE_META_REPO")"
_force_meta_year="$(atfile.util.get_envvar "${_envvar_prefix}_FORCE_META_YEAR")"
_force_now="$(atfile.util.get_envvar "${_envvar_prefix}_FORCE_NOW")"
_force_version="$(atfile.util.get_envvar "${_envvar_prefix}_FORCE_VERSION")"
_max_list="$(atfile.util.get_envvar "${_envvar_prefix}_MAX_LIST" "$_max_list_default")"
_output_json="$(atfile.util.get_envvar "${_envvar_prefix}_OUTPUT_JSON" "$_output_json_default")"
_server="$(atfile.util.get_envvar "${_envvar_prefix}_ENDPOINT_PDS")"
_skip_auth_check="$(atfile.util.get_envvar "${_envvar_prefix}_SKIP_AUTH_CHECK" "$_skip_auth_check_default")"
_skip_copyright_warn="$(atfile.util.get_envvar "${_envvar_prefix}_SKIP_COPYRIGHT_WARN" "$_skip_copyright_warn_default")"
_skip_ni_exiftool="$(atfile.util.get_envvar "${_envvar_prefix}_SKIP_NI_EXIFTOOL" "$_skip_ni_exiftool_default")"
_skip_ni_md5sum="$(atfile.util.get_envvar "${_envvar_prefix}_SKIP_NI_MD5SUM" "$_skip_ni_md5sum_default")"
_skip_ni_mediainfo="$(atfile.util.get_envvar "${_envvar_prefix}_SKIP_NI_MEDIAINFO" "$_skip_ni_mediainfo_default")"
_skip_unsupported_os_warn="$(atfile.util.get_envvar "${_envvar_prefix}_SKIP_UNSUPPORTED_OS_WARN" "$_skip_unsupported_os_warn_default")"
_password="$(atfile.util.get_envvar "${_envvar_prefix}_PASSWORD")"
_test_desktop_uas="Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"
_username="$(atfile.util.get_envvar "${_envvar_prefix}_USERNAME")"

## Read-only

_nsid_prefix="blue.zio"
_nsid_lock="${_nsid_prefix}.atfile.lock"
_nsid_meta="${_nsid_prefix}.atfile.meta"
_nsid_upload="${_nsid_prefix}.atfile.upload"
_endpoint_social_app_name="Bluesky"

case "$_endpoint_social_app" in
    "https://deer.social") _endpoint_social_app_name="Deer" ;;
esac

# Setup

## Envvar correction

### Overrides

[[ -n $_force_meta_author ]] && \
    _meta_author="$_force_meta_author" &&\
    atfile.util.print_override_envvar_debug "Copyright Author" "_meta_author"
[[ -n $_force_meta_did ]] && \
    _meta_did="$_force_meta_did" &&\
    _dist_username="$(atfile.util.get_envvar "${_envvar_prefix}_DIST_USERNAME" "$_meta_did")" &&\
    atfile.util.print_override_envvar_debug "DID" "_meta_did"
[[ -n $_force_meta_repo ]] && \
    _meta_repo="$_force_meta_repo" &&\
    atfile.util.print_override_envvar_debug "Repo URL" "_meta_author"
[[ -n $_force_meta_year ]] && \
    _meta_year="$_force_meta_year" &&\
    atfile.util.print_override_envvar_debug "Copyright Year" "_meta_year"
[[ -n $_force_now ]] && \
    _now="$_force_now" &&\
    atfile.util.print_override_envvar_debug "Current Time" "_now"
[[ -n $_force_os ]] &&\
    _os="$_force_os" &&\
    atfile.util.print_override_envvar_debug "OSL" "_os"
[[ -n $_force_version ]] && \
    _version="$_force_version" &&\
    atfile.util.print_override_envvar_debug "Version" "_version"

### Validation

[[ $_output_json == 1 ]] && [[ $_max_list == "$_max_list_default" ]] &&\
    atfile.say.debug "Setting ${_envvar_prefix}_MAX_LIST to $_max_list_fallback\n↳ ${_envvar_prefix}_OUTPUT_JSON set to 1" &&\
    _max_list=$_max_list_fallback
[[ $(( _max_list > _max_list_fallback )) == 1 ]] &&\
    atfile.say.debug "Setting ${_envvar_prefix}_MAX_LIST to $_max_list_fallback\n↳ Maximum is $_max_list_fallback" &&\
    _max_list=$_max_list_fallback

## OS detection

if [[ $_os_supported == 0 ]]; then
    if [[ $_skip_unsupported_os_warn == 0 ]]; then
        atfile.die "Unsupported OS (${_os//unknown-/})\n↳ Set ${_envvar_prefix}_SKIP_UNSUPPORTED_OS_WARN=1 to ignore"
    else
        atfile.say.debug "Skipping unsupported OS warning\n↳ ${_envvar_prefix}_SKIP_UNSUPPORTED_OS_WARN is set ($_skip_unsupported_os_warn)"
    fi
fi

## Directory creation

atfile.util.create_dir "$_path_cache"
atfile.util.create_dir "$_path_blobs_tmp"

## Program detection

_prog_hint_jq="https://jqlang.github.io/jq"

[[ "$_os" == "haiku" ]] && _prog_hint_jq="pkgman install jq"

atfile.util.check_prog "curl" "https://curl.se"
[[ $_os != "haiku" && $_os != "solaris" ]] && atfile.util.check_prog "file" "https://www.darwinsys.com/file"
atfile.util.check_prog "jq" "$_prog_hint_jq"
[[ $_skip_ni_md5sum == 0 ]] && atfile.util.check_prog "md5sum" "" "${_envvar_prefix}_SKIP_NI_MD5SUM"
#[[ $_os == "haiku" ]] && atfile.util.check_prog "perl"

# Main

## Command aliases

if [[ $_is_sourced == 0 ]]; then
    previous_command="$_command"

    case "$_command" in
        "open"|"print"|"c") _command="cat" ;;
        "rm") _command="delete" ;;
        "download"|"f"|"d") _command="fetch" ;;
        "download-crypt"|"fc"|"dc") _command="fetch-crypt" ;;
        "at") _command="handle" ;;
        "--help"|"-h") _command="help" ;;
        "get"|"i") _command="info" ;;
        "ls") _command="list" ;;
        "build") _command="release" ;;
        "did") _command="resolve" ;;
        "sb") _command="something-broke" ;;
        "js") _command="stream" ;;
        "ul"|"u") _command="upload" ;;
        "ub") _command="upload-blob" ;;
        "uc") _command="upload-crypt" ;;
        "--update"|"-U") _command="update" ;;
        "get-url"|"b") _command="url" ;;
        "--version"|"-V") _command="version" ;;
    esac

    if [[ $previous_command != "$_command" ]]; then
        atfile.say.debug "Using command '$_command' for '$previous_command'..."
    fi
fi

## Default

[[ $_is_sourced == 0 && -z $_command ]] && _command="help"

if [[ "$_command" == "atfile:"* || "$_command" == "at:"* || "$_command" == "https:"* ]]; then
    _command="handle"
    _command_args=("$1")
    atfile.say.debug "Handling '${_command_args[*]}'..."
fi

## Auth

atfile.auth

## Invoke

if [[ $_is_sourced == 0 ]]; then
    atfile.invoke "$_command" "${_command_args[@]}"
fi

atfile.util.print_seconds_since_start_debug
