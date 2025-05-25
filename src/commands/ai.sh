#!/usr/bin/env bash

function atfile.ai() {
    ai_art_record="$(com.atproto.repo.getRecord "did:plc:ragtjsm2j2vknwkz3zp4oxrd" "app.bsky.feed.post" "3jj2zikhvto2h")"
    error="$(atfile.util.get_xrpc_error $? "$ai_art_record")"

    if [[ -z "$error" ]]; then
        atfile.say "$(echo "$ai_art_record" | jq -r .value.text)"
    else
        atfile.say ":("
    fi
}
