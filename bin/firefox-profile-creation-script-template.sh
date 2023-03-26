#!/bin/bash

export LD_LIBRARY_PATH="$HOME/apps/mozilla-compat-libs:$HOME/apps/firefox:$LD_LIBRARY_PATH"
export XDG_DATA_DIRS="$HOME/apps/mozilla-compat-libs/xdg_data:$XDG_DATA_DIRS"

# export MOZ_WEBRENDER=1
# export MOZ_ACCELERATED=1

cd ~/apps/firefox && ./firefox -no-remote -CreateProfile my-custom-profile
