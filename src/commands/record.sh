#!/usr/bin/env bash

# shellcheck disable=SC2120
function atfile.record() {
    function atfile.record.output_record() {
        # shellcheck disable=SC2154
        if [[ "$_output_json" == 1 ]]; then
            echo "{ \"uri\": \"$1\", \"cid\": \"$2\", \"record\": $3 }" | jq
        else
            echo "⚡ $1"
            echo "📦 $2"
            echo "---"
            echo "$3" | jq
        fi
    }

    sub_command="$1"
    at_uri="$2"
    record="$3"

    unset record_json
    unset output_json
    unset output_return
    unset at_actor
    unset at_collection
    unset at_rkey

    if [[ "$sub_command" == "create" && "$at_uri" != "at://"* ]]; then
        # shellcheck disable=SC2154
        at_uri="at://$_username/$at_uri"
    fi

    if [[ "$sub_command" != "delete" ]] &&\
       [[ "$sub_command" != "get" ]]; then
        if [[ -z "$record" ]]; then
            atfile.die "<record> not set"
        else
            record_json="$(echo "$record" | jq)"
            # shellcheck disable=SC2181
            [[ $? != 0 ]] && atfile.die "Invalid JSON"
        fi
    fi

    [[ "$at_uri" != "at://"* ]] && atfile.die \
        "Invalid AT URI\n↳ Must be 'at://<actor>[/<collection>[/<rkey>]]'"

    at_actor="$(atfile.util.parse_at_uri "$at_uri" "actor")"
    at_collection="$(atfile.util.parse_at_uri "$at_uri" "collection")"
    at_rkey="$(atfile.util.parse_at_uri "$at_uri" "rkey")"

    case "$sub_command" in
        "create")
            if [[ -z "$at_rkey" ]]; then
                output_json="$(com.atproto.repo.createRecord "$at_actor" "$at_collection" "$record_json")"
                output_return="$?"
            else
                output_json="$(com.atproto.repo.putRecord "$at_actor" "$at_collection" "$at_rkey" "$record_json")"
                output_return="$?"
            fi
            ;;
        "delete")
            output_json="$(com.atproto.repo.deleteRecord "$at_actor" "$at_collection" "$at_rkey")"
            output_return="$?"
            ;;
        "get")
            output_json="$(com.atproto.repo.getRecord "$at_actor" "$at_collection" "$at_rkey")"
            output_return="$?"
            ;;
        "recreate")
            output_json="$(com.atproto.repo.deleteRecord "$at_actor" "$at_collection" "$at_rkey")"
            output_return="$?"
            output_json="$(com.atproto.repo.putRecord "$at_actor" "$at_collection" "$at_rkey" "$record_json")"
            output_return="$?"
            ;;
        "update")
            output_json="$(com.atproto.repo.putRecord "$at_actor" "$at_collection" "$at_rkey" "$record_json")"
            output_return="$?"
            ;;
    esac

    error="$(atfile.util.get_xrpc_error "$output_return" "$output_json")"
    [[ -n "$error" ]] && atfile.die.xrpc_error "Unable to $sub_command '$at_uri'" "$output_json"

    case "$sub_command" in
        "create"|"recreate"|"update")
            atfile.record.output_record \
                "$(echo "$output_json" | jq -r .uri)" \
                "$(echo "$output_json" | jq -r .commit.cid)" \
                "$record_json"
            ;;
        "delete")
            atfile.record.output_record \
                "$at_uri" \
                "$(echo "$output_json" | jq -r .commit.cid)" \
                "null"
            ;;
        *)
            atfile.record.output_record \
                "$(echo "$output_json" | jq -r .uri)" \
                "$(echo "$output_json" | jq -r .cid)" \
                "$(echo "$output_json" | jq -r .value)"
            ;;
    esac
}

function atfile.record_list() {
    at_uri="$1"

    unset at_actor
    unset at_collection
    unset at_rkey

    [[ "$at_uri" != "at://"* ]] && atfile.die \
        "Invalid AT URI\n↳ Must be 'at://<actor>[/<collection>]'"

    at_actor="$(atfile.util.parse_at_uri "$at_uri" "actor")"
    at_collection="$(atfile.util.parse_at_uri "$at_uri" "collection")"
    at_rkey="$(atfile.util.parse_at_uri "$at_uri" "rkey")"

    if [[ -n "$at_rkey" ]]; then
        atfile.record get "$at_uri"
        return
    fi

    atfile.die "Not yet implemented!"
}
