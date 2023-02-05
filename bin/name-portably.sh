#!/bin/bash
#
#  name-portably - make a file or directory portably named
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

include yaa-text-tools.sh

require tr
require sed

usage()
{
    echo "usage: $0 [--no-test] [--romanize] [--prettify] [file_or_directory]"
}

test=1
romanize=0
prettify=0

while [ "$1" != "" ]; do
    [[ "$1" == --no-test ]] && test=0 && shift && continue
    [[ "$1" == --romanize ]] && romanize=1 && shift && continue
    [[ "$1" == --prettify ]] && prettify=1 && shift && continue

    [[ "$1" == -h || "$1" == --help ]] && usage && exit
    [[ "$1" == -* ]] && usage 1>&2 && exit 1

    var_is_declared filename || { filename="$1" && shift && continue; }

    shift
done

# require_var test
# info "test: $test"
# flag_is_set test && info "DRY RUN"
# require_var romanize
# info "romanize: $romanize"
# require_var prettify
# info "prettify: $prettify"
# require_var filename
# info "filename: $filename"

dirname=`dirname "$filename"`
basename=`basename "$filename"`

pushd "$dirname" >/dev/null || die "Cannot change to dir $dirname"

[ -e "$basename" ] || die "file or directory $basename does not exist"

newbasename="$basename"
newbasename=`printf %s "$newbasename" | sanitize_for_windows_filename`
flag_is_set romanize && \
    newbasename=`printf %s "$newbasename" | romanize`
flag_is_set prettify && \
    newbasename=`printf %s "$newbasename" | sanitize_for_pretty_filename`
newbasename="${newbasename:-_totally_illegal_filename_it_was_}"

[[ "$basename" != "$newbasename" ]] && \
    {
        flag_is_set test && info "DRY RUN"
        info "renaming \"$basename\" to \"$newbasename\" in \"$dirname\""
        [ -e "$newbasename" ] && die "file or directory $newbasename already exists"
        flag_is_unset test && \
            {
                mv -i "$basename" "$newbasename" || die "Cannot rename $basename to $newbasename"
            }
    }

popd >/dev/null || die "popd failed"
