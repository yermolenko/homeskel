#!/bin/bash
#
#  copy-media-files-to-dir-with-new-safer-names - copying of
#  recursively found multimedia files with renaming for better
#  compatibility with various devices and filesystems
#
#  Copyright (C) 2014, 2017, 2021, 2022 Alexander Yermolenko
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

urlencode_path()
{
    local string="${1}"
    string="$( echo -n "$string" | jq -sRr @uri )"
    string=${string//%2F/\/}
    echo -n "$string"
}

romanize()
{
    cat | \
        sed 'y/абвгґджзиійклмнопрстуфхыэе/abvhgdjziijklmnoprstufhyee/' | \
        sed 'y/АБВГҐДЖЗИІЙКЛМНОПРСТУФХЫЭЕ/ABVHGDJZIIJKLMNOPRSTUFHYEE/' | \
        sed 's/[ьъ]//g; s/ё/yo/g; s/є/ye/g; s/ї/yi/g; s/ц/ts/g; s/ч/ch/g; s/ш/sh/g; s/щ/sh/g; s/ю/yu/g; s/я/ya/' | \
        sed 's/[ЬЪ]//g; s/Ё/YO/g; s/Є/YE/g; s/Ї/YI/g; s/Ц/TS/g; s/Ч/CH/g; s/Ш/SH/g; s/Щ/SH/g; s/Ю/YU/g; s/Я/YA/' | \
        tr -cd '[:alnum:]._\- '
}

romanize_string()
{
    local string="${1:?String argument is required}"
    string="$( echo -n "$string" | romanize )"
    echo -n "$string"
}

sanitize_for_m3u()
{
    sed -e "s/[^ _a-zA-Zа-яА-Я0-9\,\.\-]//g" -e 's/ \+/ /'
}

sanitize_for_m3u_string()
{
    local string="${1:?String argument is required}"
    string="$( echo -n "$string" | sanitize_for_m3u )"
    echo -n "$string"
}

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
date=`date "+%Y%m%d-%H%M%S"`

# ! touch "$scriptdir/powned.txt" > /dev/null 2>&1 || die "The script can escape the sandbox"

require jq
require tr

usage()
{
    echo "usage: $0 [--romanize] videos_dir [output_dir]"
}

romanize=0

while [ "$1" != "" ]; do
    [[ "$1" == --romanize ]] && romanize=1 && shift && continue

    [[ "$1" == -h || "$1" == --help ]] && usage && exit
    [[ "$1" == -* ]] && usage && exit

    var_is_declared videos_dir || { videos_dir="$1" && shift && continue; }
    var_is_declared output_dir || { output_dir="$1" && shift && continue; }

    shift
done

var_is_declared videos_dir || die "videos_dir is required"
var_is_declared output_dir || output_dir=`pwd`

echo "romanize: $romanize"
echo "videos_dir: $videos_dir"
echo "output_dir: $output_dir"

[ -d "$videos_dir" ] || die "Cannot read directory: $videos_dir"
[ -d "$output_dir" ] || die "Cannot access output directory: $output_dir"

videofiles=()
while IFS= read -r file; do
    videofiles+=("$file")
done < <(
    find -L "$videos_dir" -type f \
         \( -iname \*.mp4 -o -iname \*.avi \
         -o -iname \*.mpg -o -iname \*.mpeg \
         -o -iname \*.mkv -o -iname \*.webm \
         -o -iname \*.mp3 -o -iname \*.flac \
         -o -iname \*.ogg -o -iname \*.ogv \) \
         -printf '%h/%f\n' | sort -f
)

# echo "${videofiles[@]}"

for videofile in "${videofiles[@]}"
do
    videofile_title=${videofile}
    videofile_title=${videofile_title#"$videos_dir"}
    videofile_title=${videofile_title//\/aa\//\/aa\-\/}
    videofile_title=${videofile_title//\/zz\//\/zz\-\/}
    videofile_title=${videofile_title//\/ytdl\//\/yt\-\/}
    # videofile_title=${videofile_title//\/000/}
    # videofile_title=${videofile_title//\/00/}
    # videofile_title=${videofile_title//\/0/}
    videofile_title=${videofile_title//\//}

    # special case for ytdl downloads
    info_json_file="${videofile%.mp4}.info.json"
    [ -f "$info_json_file" ] && \
        title_from_info_json=$(jq -r ".title" "$info_json_file") && \
        upload_date_from_info_json=$(jq -r ".upload_date" "$info_json_file") && \
        videofile_title="$upload_date_from_info_json - $title_from_info_json - $videofile_title"

    [ $romanize -eq 1 ] && \
        videofile_title="$( romanize_string "$videofile_title" )"
    videofile_title="$( sanitize_for_m3u_string "$videofile_title" )"

    cp -H "$videofile" "$output_dir/$videofile_title" || die "Cannot copy file to the destination"
done
