#!/usr/bin/env bash

function atfile.say() {
    message="$1"
    prefix="$2"
    color_prefix="$3"
    color_message="$4"
    color_prefix_message="$5"
    suffix="$6"
    
    prefix_length=0

    # shellcheck disable=SC2154
    if [[ $_os == "haiku" ]]; then
        message="${message//↳/>}"
    fi
    
    [[ -z $color_prefix_message ]] && color_prefix_message=0
    [[ -z $suffix ]] && suffix="\n"
    [[ $suffix == "\\" ]] && suffix=""
    
    if [[ -z $color_message ]]; then
        color_message="\033[0m"
    else
        color_message="\033[${color_prefix_message};${color_message}m"
    fi
    
    if [[ -z $color_prefix ]]; then
        color_prefix="\033[0m"
    else
        color_prefix="\033[1;${color_prefix}m"
    fi
    
    if [[ -n $prefix ]]; then
        if [[ $prefix == *":"* ]]; then
            prefix_length=${#prefix}
            prefix="${color_prefix}${prefix}\033[0m"
        else
            prefix_length=$(( ${#prefix} + 2 ))
            prefix="${color_prefix}${prefix}: \033[0m"
        fi
    fi
    
    message="${message//\\n/\\n$(atfile.util.repeat_char " " "$prefix_length")}"
    
    echo -n -e "${prefix}${color_message}$message\033[0m${suffix}"
}

function atfile.say.debug() {
    message="$1"
    prefix="$2"

    [[ -z "$prefix" ]] && prefix="Debug"

    if [[ $_debug == 1 ]]; then
        atfile.say "$message" "$prefix" 35 >&2
    fi
}

function atfile.say.die() {
    message="$1"
    atfile.say "$message" "Error" 31 31 1 >&2
}

function atfile.say.inline() {
    message="$1"
    color="$2"
    atfile.say "$message" "" "" "$color" "" "\\"
}
