#!/bin/bash
#
#  ytdl-extract-cookies - extract browser cookies for convenient
#  downloading of videos
#
#  Copyright (C) 2014, 2017, 2021, 2022, 2023, 2025 Alexander Yermolenko
#  <yaa.mbox@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

die()
{
    local msg=${1:-"Unknown error"}
    shift
    echo "ERROR: $msg $@" 1>&2
    exit 1
}

goodbye()
{
    local msg=${1:-"Cancelled by user"}
    shift
    echo "INFO: $msg $@" 1>&2
    exit 1
}

info()
{
    local msg=${1:-"Info"}
    shift
    echo "INFO: $msg $@" 1>&2
}

require()
{
    local cmd=${1:?"Command name is required"}
    local extra_info=${2:+"\nNote: $2"}
    hash $cmd 2>/dev/null || die "$cmd not found$extra_info"
}

require_var()
{
    declare -p "$1" >/dev/null 2>&1 || die "$1 is not declared"
}

check_var()
{
    declare -p "$1" >/dev/null 2>&1 && echo "$1: OK" || echo "$1: is not declared"
}

var_is_declared()
{
    declare -p "$1" >/dev/null 2>&1
}

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
date=`date "+%Y%m%d-%H%M%S"`

# ! touch "$scriptdir/powned.txt" > /dev/null 2>&1 || die "The script can escape the sandbox"

# hostname=$( hostname )
# if [ "x$hostname" != "xdownloader" ]
# then
#    die "Running youtube-dl on this host is undesired"
# fi

usage()
{
    echo "usage: $0 [--extract-cookies-to-file <cookies-file>]"
}

cookies_file="ytdl-cookies.txt"

while [ "$1" != "" ]; do
    [[ "$1" == --extract-cookies-to-file ]] && shift && cookies_file="${1:?Bad cookies file specification}" && shift && continue

    [[ "$1" == -h || "$1" == --help ]] && usage && exit
    [[ "$1" == -* ]] && usage && exit

    shift
done

echo "cookies_file: $cookies_file"

ytdl_executable=./youtube-dl
[ -f "$ytdl_executable" ] || ytdl_executable="$scriptdir/youtube-dl"
[ -f "$ytdl_executable" ] || { ytdl_executable=$(which youtube-dl); require youtube-dl; }

echo "ytdl_executable: $ytdl_executable"

ytdl_command_extract_cookies=()
#ytdl_command_extract_cookies+=(/usr/bin/python3)
ytdl_command_extract_cookies+=("$ytdl_executable")
ytdl_command_extract_cookies+=(--ignore-errors)
ytdl_command_extract_cookies+=(--cookies-from-browser firefox --cookies "$cookies_file")
# ytdl_command_extract_cookies+=(--cookies-from-browser firefox:xxxxxxx.default-release --cookies "$cookies_file")

sleep 5

"${ytdl_command_extract_cookies[@]}" 2>/dev/null
