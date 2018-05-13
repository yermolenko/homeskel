#/bin/bash

emacsclient -a mcedit "$@" && \
    emacsclient -a true -e "(suspend-frame)" 1>/dev/null 2>/dev/null \
        || editor "$@"
