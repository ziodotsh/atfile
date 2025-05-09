#!/usr/bin/env bash

# PDS

function atfile.xrpc.pds.blob() {
    file="$1"
    type="$2"
    lexi="$3"

    [[ -z $lexi ]] && lexi="com.atproto.repo.uploadBlob"
    [[ -z $type ]] && type="*/*"

    atfile.http.upload \
        "$_server/xrpc/$lexi" \
        "$file" \
        "Bearer $(atfile.xrpc.pds.jwt)" \
        "$type" | jq
}

function atfile.xrpc.pds.get() {
    lexi="$1"
    query="$2"
    type="$3"
    endpoint="$4"

    [[ -z $endpoint ]] && endpoint="$_server"

    atfile.http.get \
        "$endpoint/xrpc/$lexi?$query" \
        "Bearer $(atfile.xrpc.pds.jwt)" \
        "$type" | jq
}

function atfile.xrpc.pds.jwt() {
    atfile.http.post \
        "$_server/xrpc/com.atproto.server.createSession" \
        '{"identifier": "'"$_username"'", "password": "'"$_password"'"}' | jq -r ".accessJwt"
}

function atfile.xrpc.pds.post() {
    lexi="$1"
    data="$2"
    type="$3"

    [[ -z $type ]] && type="application/json"

    curl -s -X POST "$_server/xrpc/$lexi" \
        -H "Authorization: Bearer $(atfile.xrpc.pds.jwt)" \
        -H "Content-Type: $type" \
        -H "User-Agent: $(atfile.util.get_uas)" \
        -d "$data" | jq
}

# AppView

## Bluesky

function atfile.xrpc.bsky.get() {
    lexi="$1"
    query="$2"
    type="$3"
    appview="$4"

    # shellcheck disable=SC2154
    [[ -z "$appview" ]] && appview="$_endpoint_appview"

    atfile.http.get \
        "$appview/xrpc/$lexi?$query" \
        "" \
        "$type" | jq
}
