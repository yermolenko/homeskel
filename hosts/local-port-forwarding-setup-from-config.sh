#!/bin/bash

source ./host-config || exit 1
source ../yaa-ssh-tricks.sh || exit 1

# local_port_forwarding_setup_from_config
local_port_forwarding_setup_from_config_single_connection
