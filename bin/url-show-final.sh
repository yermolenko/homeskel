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

require curl

url_effective=`curl --silent --location --head --output /dev/null --write-out '%{url_effective}' -- "$url";`

echo "url_effective: $url_effective"
