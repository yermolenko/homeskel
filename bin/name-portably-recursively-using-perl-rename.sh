#!/bin/bash
#
#  name-portably-recursively-using-perl-rename - give portable
#  filenames recursively using perl rename
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

require rename
rename 2>&1 | grep -q perlexpr || \
    die "existing rename (`which rename`) is not a perl rename utility"

usage()
{
    echo "usage: $0 [--no-test] [file_or_directory]"
}

test=1

while [ "$1" != "" ]; do
    [[ "$1" == --no-test ]] && test=0 && shift && continue

    [[ "$1" == -h || "$1" == --help ]] && usage && exit
    [[ "$1" == -* ]] && usage 1>&2 && exit 1

    var_is_declared dirname || { dirname="$1" && shift && continue; }

    shift
done

var_is_declared dirname || dirname=`pwd`

require_var test
# info "test: $test"
flag_is_set test && info "DRY RUN"
require_var dirname
info "dirname: $dirname"

[ -e "$dirname" ] || die "file or directory $dirname does not exist"

rename_options=(-v)
flag_is_set test && \
    rename_options+=(-n)

info "rename_options: ${rename_options[@]}"

info "Processing files"

find "$dirname" -mount -type f -print0 | \
    xargs -0 -I {} -P 1 \
          rename "${rename_options[@]}" \
          's/[*"<>|\\\n\?]//g;
           s/:/-/g;
           s/^\s*//;
           s/\s*$//;
           s/\.+$//g; ' \
          '{}'

info "Processing directories"

find "$dirname" -mount -type d -print0 | \
    xargs -0 -I {} -P 1 \
          rename "${rename_options[@]}" \
          's/[*"<>|\\\n\?]//g;
           s/:/-/g;
           s/^\s*//;
           s/\s*$//;
           s/\.+$//g; ' \
          '{}'
