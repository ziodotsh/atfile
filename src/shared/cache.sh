#!/usr/bin/env bash

function atfile.cache.debug() {
    key="$1"
    action="$2"
    output="$3"

    [[ -z "$output" ]] && output="(Empty)"

    atfile.say.debug "$action '$key' cache...\n↳ $output"
}

function atfile.cache.del() {
    key="$(atfile.util.get_cache_path "$1")"

    atfile.cache.debug "$1" "Deleting"
    [[ -f "$key" ]] && rm "$key"
}

function atfile.cache.get() {
    key="$(atfile.util.get_cache_path "$1")"
    unset value

    atfile.cache.debug "$1" "Getting" "$value"
    [[ -f "$key" ]] && value="$(cat $key)"
    echo "$value"
}

function atfile.cache.set() {
    key="$(atfile.util.get_cache_path "$1")"
    value="$2"

    atfile.cache.debug "$1" "Setting" "$value"
    # shellcheck disable=SC2154
    mkdir -p "$_path_cache"
    echo "$value" > "$key"
    echo "$value"
}
