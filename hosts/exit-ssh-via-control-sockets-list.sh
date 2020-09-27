#!/bin/bash

source ./host-config || exit 1
source ../yaa-ssh-tricks.sh || exit 1

exit_ssh_via_control_sockets_list "$@"
