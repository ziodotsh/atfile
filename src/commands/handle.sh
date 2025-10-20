#!/usr/bin/env bash

function atfile.handle() {
    uri="$1"
    handler="$2"

    function atfile.handle.is_temp_file_needed() {
        handler="${1//.desktop/}"
        type="$2"

        handlers_needing_tmp_file=(
            "app.drey.EarTag"
            "com.github.neithern.g4music"
        )

        if [[ ${handlers_needing_tmp_file[*]} =~ $handler ]]; then
            echo 1
        elif [[ $type == "text/"* ]]; then
            echo 1
        else
            echo 0
        fi
    }

    # shellcheck disable=SC2154
    [[ $_output_json == 1 ]] && atfile.die "Command not available as JSON"

    actor="$(echo "$uri" | cut -d "/" -f 3)"
    key="$(echo "$uri" | cut -d "/" -f 4)"

    # shellcheck disable=SC2154
    atfile.util.create_dir "$_path_blobs_tmp"

    if [[ -n "$actor" && -n "$key" ]]; then
        atfile.util.override_actor "$actor"

        # shellcheck disable=SC2154
        atfile.say.debug "Getting record...\n↳ NSID: $_nsid_upload\n↳ Repo: $_username\n↳ Key: $key"
        record="$(com.atproto.repo.getRecord "$_username" "$_nsid_upload" "$key")"
        error="$(atfile.util.get_xrpc_error $? "$record")"
        [[ -n "$error" ]] && atfile.die.gui.xrpc_error "Unable to get '$key'" "$error"

        blob_cid="$(echo "$record" | jq -r ".value.blob.ref.\"\$link\"")"
        blob_uri="$(atfile.util.build_blob_uri "$_username" "$blob_cid")"
        file_type="$(echo "$record" | jq -r '.value.file.mimeType')"

        # shellcheck disable=SC2154
        if [[ $_os == "linux"* ]] && \
            [ -x "$(command -v xdg-mime)" ] && \
            [ -x "$(command -v xdg-open)" ] && \
            [ -x "$(command -v gtk-launch)" ]; then

            # HACK: Open with browser if $file_type isn't set
            [[ -z $file_type ]] && file_type="text/html"

            if [[ -z $handler ]]; then
                atfile.say.debug "Querying for handler '$file_type'..."
                handler="$(xdg-mime query default "$file_type")"
            else
                handler="$handler.desktop"
                atfile.say.debug "Handler manually set to '$handler'"
            fi

            # shellcheck disable=SC2319
            # shellcheck disable=SC2181
            if [[ -n $handler ]] || [[ $? != 0 ]]; then
                atfile.say.debug "Opening '$key' ($file_type) with '${handler//.desktop/}'..."

                # HACK: Some apps don't like http(s)://; we'll need to handle these
                if [[ $(atfile.handle.is_temp_file_needed "$handler" "$file_type") == 1 ]]; then
                    atfile.say.debug "Unsupported for streaming"

                    download_success=1
                    # shellcheck disable=SC2154
                    tmp_path="$_path_blobs_tmp/$blob_cid"

                    if ! [[ -f "$tmp_path" ]]; then
                        atfile.say.debug "Downloading '$blob_cid'..."
                        atfile.http.download "$blob_uri" "$tmp_path"
                        [[ $? != 0 ]] && download_success=0
                    else
                        atfile.say.debug "Blob '$blob_cid' already exists"
                    fi

                    if [[ $download_success == 1 ]]; then
                        atfile.say.debug "Launching '$handler'..."
                        gtk-launch "$handler" "$tmp_path" </dev/null &>/dev/null &
                    else
                        atfile.die.gui \
                            "Unable to download '$key'"
                    fi
                else
                    atfile.say.debug "Launching '$handler'..."
                    gtk-launch "$handler" "$blob_uri" </dev/null &>/dev/null &
                fi
            else
                atfile.say.debug "No handler for '$file_type'. Launching URI..."
                atfile.util.launch_uri "$blob_uri"
            fi
        else
            atfile.say.debug "Relevant tools not installed. Launching URI..."
            atfile.util.launch_uri "$blob_uri"
        fi
    else
        atfile.die.gui \
            "Invalid ATFile URI\n↳ Must be 'atfile://<actor>/<key>'" \
            "Invalid ATFile URI"
    fi
}
