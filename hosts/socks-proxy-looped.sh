#!/bin/bash

source ./host-config || exit 1
source ../yaa-ssh-tricks.sh || exit 1

while true
do
    info "$(timestamp): starting socks proxy ..."
    socks_proxy
    sleep 64
done
