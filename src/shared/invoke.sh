#!/usr/bin/env bash

function atfile.invoke() {
    command="$1"
    shift
    args=("$@")

    if [[ $_is_sourced == 0 ]] && [[ $ATFILE_DEVEL_NO_INVOKE != 1 ]]; then
        atfile.say.debug "Invoking '$command'...\n↳ Arguments: ${args[*]}"

        case "$command" in
            "ai")
                atfile.ai
                ;;
            "blob")
                case "${args[0]}" in
                    "list"|"ls"|"l") atfile.invoke.blob_list "${args[1]}" ;;
                    "upload"|"u") atfile.invoke.blob_upload "${args[1]}" ;;
                    *) atfile.die.unknown_command "$(echo "$command ${args[0]}" | xargs)" ;;
                esac  
                ;;
            "bsky")
                if [[ -z "${args[0]}" ]]; then
                    atfile.util.override_actor "$_username"
                    atfile.bsky_profile "$_username"
                else
                    atfile.bsky_profile "${args[0]}"
                fi
                ;;
            "cat")
                [[ -z "${args[0]}" ]] && atfile.die "<key> not set"
                if [[ -n "${args[1]}" ]]; then
                    atfile.util.override_actor "${args[1]}"
                fi
                
                atfile.invoke.print "${args[0]}"
                ;;
            "delete")
                [[ -z "${args[0]}" ]] && atfile.die "<key> not set"
                atfile.invoke.delete "${args[0]}"
                ;;
            "fetch")
                [[ -z "${args[0]}" ]] && atfile.die "<key> not set"
                if [[ -n "${args[1]}" ]]; then
                    atfile.util.override_actor "${args[1]}"
                fi
                
                atfile.invoke.download "${args[0]}"
                ;;
            "fetch-crypt")
                atfile.util.check_prog_gpg
                [[ -z "${args[0]}" ]] && atfile.die "<key> not set"
                if [[ -n "${args[1]}" ]]; then
                    atfile.util.override_actor "${args[1]}"
                fi
                
                atfile.invoke.download "${args[0]}" 1
                ;;
            "handle")
                uri="${args[0]}"
                protocol="$(atfile.util.get_uri_segment "$uri" protocol)"

                if [[ $protocol == "https" ]]; then
                    http_uri="$uri"
                    uri="$(atfile.util.map_http_to_at "$http_uri")"

                    atfile.say.debug "Mapping '$http_uri'..."
                    
                    if [[ -z "$uri" ]]; then
                        atfile.die "Unable to map '$http_uri' to at:// URI"
                    else
                        protocol="$(atfile.util.get_uri_segment "$uri" protocol)"
                    fi
                fi

                atfile.say.debug "Handling protocol '$protocol://'..."

                case $protocol in
                    "at") atfile.invoke.handle_aturi "$uri" ;;
                    "atfile") atfile.invoke.handle_atfile "$uri" "${args[1]}" ;;
                esac
                ;;
            "help")
                atfile.help
                ;;
            "info")
                [[ -z "${args[0]}" ]] && atfile.die "<key> not set"
                if [[ -n "${args[1]}" ]]; then
                    atfile.util.override_actor "${args[1]}"
                fi
                
                atfile.invoke.get "${args[0]}"
                ;;
            "install")
                # TODO: Disable when installed (how?), similar to `release`
                atfile.install "${args[0]}" "${args[1]}" "${args[2]}"
                ;;
            "list")
                if [[ "${args[0]}" == *.* || "${args[0]}" == did:* ]]; then
                    # NOTE: User has entered <actor> in the wrong place, so we'll fix it
                    #       for them
                    # BUG:  Keys with periods in them can't be used as a cursor
                    
                    atfile.util.override_actor "${args[0]}"

                    atfile.invoke.list "${args[1]}"
                else
                    if [[ -n "${args[1]}" ]]; then
                        atfile.util.override_actor "${args[1]}"
                    fi
                    atfile.invoke.list "${args[0]}"   
                fi
                ;;
            "lock")
                atfile.invoke.lock "${args[0]}" 1
                ;;
            "now")
                atfile.now "${args[0]}"
                ;;
            "record")
                # NOTE: Performs no validation (apart from JSON)! Here be dragons
                case "${args[0]}" in
                    "add"|"create"|"c") atfile.record "create" "${args[1]}" "${args[2]}" ;;
                    "get"|"g") atfile.record "get" "${args[1]}" ;;
                    "ls"|"list"|"l") atfile.record_list "${args[1]}" ;;
                    "put"|"update"|"u") atfile.record "update" "${args[1]}" "${args[2]}" ;;
                    "rc"|"recreate"|"r") atfile.record "recreate" "${args[1]}" "${args[2]}" ;;
                    "rm"|"delete"|"d") atfile.record "delete" "${args[1]}" ;;
                    *) atfile.die.unknown_command "$(echo "$command ${args[0]}" | xargs)" ;;
                esac
                ;;
            "release")
                if [[ $ATFILE_DEVEL == 1 ]]; then
                    atfile.release
                else
                    atfile.die.unknown_command "$command"
                fi
                ;;
            "resolve")
                atfile.resolve "${args[0]}"
                ;;
            "something-broke")
                atfile.something_broke
                ;;
            "stream")
                atfile.stream "${args[0]}" "${args[1]}" "${args[2]}" "${args[3]}"
                ;;
            "token")
                atfile.invoke.token
                ;;
            "toggle-mime")
                atfile.invoke.toggle_desktop
                ;;
            "upload")
                atfile.util.check_prog_optional_metadata
                [[ -z "${args[0]}" ]] && atfile.die "<file> not set"
                atfile.invoke.upload "${args[0]}" "" "${args[1]}"
                ;;
            "upload-crypt")
                atfile.util.check_prog_optional_metadata
                atfile.util.check_prog_gpg
                [[ -z "${args[0]}" ]] && atfile.die "<file> not set"
                [[ -z "${args[1]}" ]] && atfile.die "<recipient> not set"
                atfile.invoke.upload "${args[0]}" "${args[1]}" "${args[2]}"
                ;;
            "unlock")
                atfile.invoke.lock "${args[0]}" 0
                ;;
            "update")
                atfile.update install
                ;;
            "url")
                [[ -z "${args[0]}" ]] && atfile.die "<key> not set"
                if [[ -n "${args[1]}" ]]; then
                    atfile.util.override_actor "${args[1]}"
                fi
                
                atfile.invoke.get_url "${args[0]}"
                ;;
            "version")
                echo -e "$_version"
                atfile.cache.del "update-check"
                atfile.update check-only
                ;;
            *)
                atfile.die.unknown_command "$command"
                ;;
        esac

        atfile.update check-only
    fi
}
