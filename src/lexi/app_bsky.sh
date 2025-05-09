#!/usr/bin/env bash

# app.bsky.*

## Queries

function app.bsky.actor.getProfile() {
    actor="$1"
    
    # NOTE: AppViewLite does not fully support app.bsky.actor.getProfile
    # shellcheck disable=SC2154
    appview="$_endpoint_appview_fallback"
    # shellcheck disable=SC2154
    [[ $_disable_pbc_fallback == 1 ]] && unset appview

    atfile.xrpc.bsky.get "app.bsky.actor.getProfile" "actor=$actor" "" "$appview"
}

function app.bsky.labeler.getServices() {
    did="$1"

    # NOTE: AppViewLite does not fully support app.bsky.labeler.getServices
    # shellcheck disable=SC2154
    appview="$_endpoint_appview_fallback"
    # shellcheck disable=SC2154
    [[ $_disable_pbc_fallback == 1 ]] && unset appview
    
    atfile.xrpc.bsky.get "app.bsky.labeler.getServices" "dids=$did"
}
