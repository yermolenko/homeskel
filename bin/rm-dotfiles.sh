#!/bin/bash
#
#  rm-dotfiles - remove dot files and directories
#
#  Copyright (C) 2022, 2023 Alexander Yermolenko <yaa.mbox@gmail.com>
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

# include yaa-text-tools.sh

require find
require rm

usage()
{
    echo "usage: $0 [--no-test] [--maxdepth <maxdepth>] directory"
}

test=1

while [ "$1" != "" ]; do
    [[ "$1" == --no-test ]] && test=0 && shift && continue
    [[ "$1" == --maxdepth ]] && shift && maxdepth="${1:?Bad maxdepth specification}" && shift && continue

    [[ "$1" == -h || "$1" == --help ]] && usage && exit
    [[ "$1" == -* ]] && usage 1>&2 && exit 1

    var_is_declared directory || { directory="$1" && shift && continue; }

    shift
done

var_is_declared directory || directory=`pwd`

var_is_declared maxdepth && info "maxdepth: $maxdepth"
info "test: $test"
info "directory: $directory"

find_command+=(find "$directory")
find_command+=(-mindepth 1)
var_is_declared maxdepth && \
    find_command+=(-maxdepth "$maxdepth")
find_command+=(-name '\.*')
# find_command+=(-a \( -type f -o -type d \))
find_command+=(-prune)
flag_is_set test && \
    find_command+=(-exec sh -c "printf \"{}\n\"" \;) || \
        find_command+=(-exec sh -c "printf \"{}\n\" && rm -rf \"{}\"" \;)

if flag_is_unset test;
then
    echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
        read -p "Are you sure to delete dotted files and directories recursively? " -n 1 && \
        [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

    echo ""
    echo  "Deleting dotted files and directories recursively ... "
fi

"${find_command[@]}"
