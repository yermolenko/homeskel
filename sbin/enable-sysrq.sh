#!/bin/bash

die()
{
    local msg=${1:-"Unknown error"}
    shift
    echo "ERROR: $msg $@" 1>&2
    exit 1
}

[ "$EUID" -eq 0 ] || die "Superuser privileges required"

echo "1" > /proc/sys/kernel/sysrq
