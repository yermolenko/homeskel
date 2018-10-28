#!/bin/bash

die()
{
    msg=${1:-"Unknown Error"}
    echo "ERROR: $msg" 1>&2
    exit 1
}

info()
{
    msg=${1:-"Info"}
    echo "INFO: $msg" 1>&2
}

require()
{
    local cmd=${1:?"Command name is required"}
    local extra_info=${2:+"\nNote: $2"}
    hash $cmd 2>/dev/null || die "$cmd not found$extra_info"
}

# [ "$EUID" -eq 0 ] || info "This program is supposed to be run with superuser privileges"

require getfacl

dirname=${1:-.}

getfacl --recursive --skip-base --absolute-names "$dirname"
