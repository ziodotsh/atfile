#!/usr/bin/env bash

function atfile.now() {
    date="$1"
    atfile.util.get_date "$date"
}
