#!/bin/bash

source ./host-config || exit 1
source ../yaa-ssh-tricks.sh || exit 1

vnc_run_ssvncviewer_viewonly "$@"
