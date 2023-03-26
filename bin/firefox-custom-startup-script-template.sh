#!/bin/bash

export LD_LIBRARY_PATH="$HOME/apps/mozilla-compat-libs:$HOME/apps/firefox:$LD_LIBRARY_PATH"
export XDG_DATA_DIRS="$HOME/apps/mozilla-compat-libs/xdg_data:$XDG_DATA_DIRS"

# export MOZ_WEBRENDER=1
# export MOZ_ACCELERATED=1

cd ~/apps/firefox && ./firefox "$@"

# cd ~/apps/firefox && ./firefox -no-remote -P my-custom-profile "$@"
# cd ~/apps/firefox && ./firefox -no-remote -P ffsync-pcA "$@"
# cd ~/apps/firefox && ./firefox -no-remote -P ffsync_idX-pcA "$@"
# cd ~/apps/firefox && ./firefox -no-remote -P fin-bankX-pcA "$@"
# cd ~/apps/firefox && ./firefox -no-remote -P tg-numberX-pcA "$@"
# cd ~/apps/firefox && ./firefox -no-remote -P job-companyX-pcA "$@"
