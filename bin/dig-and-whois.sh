#/bin/bash

hostname=${1:?Fully specified hostname is required}

dig +short "$hostname" | \
    xargs -i bash -c 'echo "==== Info for {} ====" ; whois {} ; (true)' | \
    grep -v "^%"
