#/bin/bash

url=${1:?URL is required}

die()
{
    local msg=${1:-"Unknown error"}
    echo "ERROR: $msg" 1>&2
    exit 1
}

require()
{
    local cmd=${1:?"Command name is required"}
    local extra_info=${2:+"\nNote: $2"}
    hash $cmd 2>/dev/null || die "$cmd not found$extra_info"
}

chromium_executable=chromium-browser
hash "$chromium_executable" 2>/dev/null || chromium_executable=chromium

require "$chromium_executable"
require tr
require jq

printf 'location.href\nquit\n' | \
    "$chromium_executable" --headless --disable-gpu --disable-software-rasterizer \
                     --disable-dev-shm-usage --no-sandbox --repl "$url" 2> /dev/null \
    | tr -d '>>> ' | jq -r '.result.value'
