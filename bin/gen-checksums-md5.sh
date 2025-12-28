#!/bin/bash
#
#  gen-checksums-md5.sh - convenient MD5SUMS file generator
#
#  Copyright (C) 2025 Alexander Yermolenko <yaa.mbox@gmail.com>
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

item=${1:-./}

[ ! -e "$item" ] && echo "ERROR: directory or file does not exist!" && exit 1

if [ -d "$item" ]
then
    checksums_output_dir=`pwd`

    if [[ $item == . || $item == ./ ]]
    then
        checksums_filename=MD5SUMS
    else
        checksums_filename=`basename "$item"`.MD5SUMS
    fi

    cd "$item" || { echo "ERROR: cannot cd to the directory!"; exit 1; }

    [ -e "$checksums_output_dir/$checksums_filename" ] && \
        { echo "ERROR: checksums file already exists!"; exit 1; }

    export LANG=en_US.UTF-8
    export LC_COLLATE=C

    find . -type f \
         -and -not -path "./MD5SUMS" \
         -and -not -path "./MD5SUMS"-cp1251 \
         -print0 | sort -z | xargs -0 md5sum > "$checksums_output_dir/$checksums_filename"
else
    checksums_filename="$item".md5

    [ -e "$checksums_filename" ] && echo "ERROR: checksums file already exists!" && exit 1

    md5sum "$item" > "$checksums_filename"
fi

# konwert utf8-cp1251 "$checksums_filename" -o "$checksums_filename"-cp1251
