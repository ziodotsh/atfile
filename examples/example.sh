#!/usr/bin/env bash

_atfile_path="$(dirname "$(realpath "$0")")/../atfile.sh"

if [[ ! -f "$_atfile_path" ]]; then
    echo -e "\033[1;31mError: ATFile not found (download: https://zio.sh/atfile)\033[0m"
    exit 0
fi

# shellcheck disable=SC1090
source "$_atfile_path"

atfile.bsky_profile "ducky.ws"
