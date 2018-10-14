#!/bin/bash

die()
{
    msg=${1:-"Unknown Error"}
    echo "ERROR: $msg" 1>&2
    exit 1
}

[ "$EUID" -eq 0 ] || die "Superuser privileges required"

sysctl vm.min_free_kbytes
#sysctl vm.min_free_kbytes=65536
#sysctl vm.min_free_kbytes=131072
sysctl vm.min_free_kbytes=256000

sysctl vm.swappiness
#sysctl vm.swappiness=30
#sysctl vm.swappiness=5
sysctl vm.swappiness=20

sysctl vm.vfs_cache_pressure
#sysctl vm.vfs_cache_pressure=50
sysctl vm.vfs_cache_pressure=25
