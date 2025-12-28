#!/bin/bash
#
#  shuffle-for-media-player - shuffle multimedia files by renaming them
#
#  Copyright (C) 2022, 2023, 2024 Alexander Yermolenko
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

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$scriptdir/yaa-tools.sh" 2>/dev/null || \
    source "yaa-tools.sh" || exit 1
date=`date "+%Y%m%d-%H%M%S"`

include yaa-text-tools.sh

usage()
{
    echo "usage: $0 [--no-test] [--unshuffle] working_directory"
}

test=1
unshuffle=0

while [ "$1" != "" ]; do
    [[ "$1" == --no-test ]] && test=0 && shift && continue
    [[ "$1" == --unshuffle ]] && unshuffle=1 && shift && continue

    [[ "$1" == -h || "$1" == --help ]] && usage && exit
    [[ "$1" == -* ]] && usage 1>&2 && exit 1

    var_is_declared working_directory || { working_directory="$1" && shift && continue; }

    shift
done

var_is_declared working_directory || working_directory=./

info "test: $test"
info "unshuffle: $unshuffle"
info "working_directory: $working_directory"

cd "$working_directory" || die "Cannot change dir to \"$working_directory\""

files=()
while IFS= read -r file; do
    files+=("$file")
done < <(
    find -L "." -maxdepth 1 -type f \
         \( -iname \*.mp4 -o -iname \*.avi \
         -o -iname \*.mpg -o -iname \*.mpeg \
         -o -iname \*.mkv -o -iname \*.webm \
         -o -iname \*.mp3 -o -iname \*.flac \
         -o -iname \*.ogg -o -iname \*.ogv \) \
         -printf '%f\n' | sort -f
)

for file in "${files[@]}"
do
    if [[ $file =~ ^1[0-9]{4,10}-(.*)$ ]]
    then
        name=${BASH_REMATCH[1]}
        file_is_shuffled=1
    else
        name=${file}
        file_is_shuffled=0
    fi

    if flag_is_unset test;
    then
        if flag_is_unset unshuffle;
        then
            shuffled_name="1$(printf "%06d" $RANDOM)-$name"
            mv "$file" "$shuffled_name" || \
                die "Cannot shuffle file \"$file\""
        else
            if flag_is_set file_is_shuffled;
            then
                [ ! -e "$name" ] && \
                    mv "$file" "$name" || \
                        die "Cannot unshuffle file \"$file\""
            fi
        fi
    else
        if flag_is_unset unshuffle;
        then
            info "Found file \"$file\" (guessed unshuffled name: \"$name\")"
        else
            flag_is_set file_is_shuffled || \
                info "WARNING: file \"$file\" is unshuffled, but unshuffling have been requested"
        fi
    fi
done
