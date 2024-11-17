#!/bin/bash

pinghost="google.com"
datehost="http://google.com"

export http_proxy=http://10.0.2.1:8080

# sleep 50

declare -p http_proxy >/dev/null 2>&1 ||
    {
        if ( ! ping -c5 -i1 -n -s10 -W1 "$pinghost" &>/dev/null ); then
            echo "ERROR: Network in unreachable."
            exit 1
        fi
    }

newdate="$(wget --delete-after --server-response -- "$datehost" 2>&1 |
        grep -E '^[[:space:]]*[dD]ate:' |
        sed 's/^[[:space:]]*[dD]ate:[[:space:]]*//' |
        tail -n 1 | awk '{print $1, $3, $2,  $5 ,"GMT", $4 }' |
        sed 's/,//')"

echo "Setting date to: $newdate"

date -s "$newdate"
