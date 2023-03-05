#!/bin/bash

die()
{
    local msg=${1:-"Unknown error"}
    shift
    echo "ERROR: $msg $@" 1>&2
    exit 1
}

[ "$EUID" -eq 0 ] || die "Superuser privileges required"

[ -e /usr/bin/ibus-daemon ] || die "Cannot find ibus-daemon"

dpkg-divert --package im-config --rename /usr/bin/ibus-daemon && \
    echo "Note: reboot the system to apply changes"
