#!/bin/bash

source ./host-config || exit 1
source ../yaa-ssh-tricks.sh || exit 1

socks_proxy_setup
