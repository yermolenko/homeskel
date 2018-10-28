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

[ "$EUID" -eq 0 ] || info "This program is supposed to be run with superuser privileges"

require dpkg

date=`date +"%Y%m%d_%H%M%S"`

find /boot \
     -xdev \
     ! -type d \
     -exec sh -c "dpkg -S \"{}\" || ls -la \"{}\" >> \"not-in-dpkg-$date-boot\" " \;

find / \
     -xdev \
     -path /home -prune -o \
     -path /home_in_root -prune -o \
     -path /srv -prune -o \
     -path /root -prune -o \
     -path /usr/local/games -prune -o \
     -path /var/log -prune -o \
     -path /var/lib/schroot -prune -o \
     ! -type d \
     ! -iname \*.pyc \
     ! -iname \*.elc \
     -exec sh -c "dpkg -S \"{}\" || ls -la \"{}\" >> \"not-in-dpkg-$date\" " \;
