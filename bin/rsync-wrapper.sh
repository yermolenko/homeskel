#!/bin/bash
#
#  rsync-wrapper.sh - copy files, directories or directory structures
#  using rsync
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

require rsync

rsync_bwlimit="10000"
rsync_bwlimit="0"

usage()
{
    echo "usage: $0 [--no-test] [--directory-structure-only] [--numeric-ids] [--update] [--ntfs-friendly] src dest"
}

test=1
directory_structure_only=0
numeric_ids=0
update=0
ntfs_friendly_rsync=0

while [ "$1" != "" ]; do
    [[ "$1" == --no-test ]] && test=0 && shift && continue
    [[ "$1" == --directory-structure-only ]] && directory_structure_only=1 && shift && continue
    [[ "$1" == --numeric-ids ]] && numeric_ids=1 && shift && continue
    [[ "$1" == --update ]] && update=1 && shift && continue
    [[ "$1" == --ntfs-friendly ]] && ntfs_friendly_rsync=1 && shift && continue

    [[ "$1" == -h || "$1" == --help ]] && usage && exit
    [[ "$1" == -* ]] && usage 1>&2 && exit 1

    var_is_declared src || { src="$1" && shift && continue; }
    var_is_declared dest || { dest="$1" && shift && continue; }

    shift
done

require_var test
flag_is_set test && info "DRY RUN"
require_var directory_structure_only
info "directory_structure_only: $directory_structure_only"
require_var numeric_ids
info "numeric_ids: $numeric_ids"
require_var update
info "update: $update"
require_var ntfs_friendly_rsync
info "ntfs_friendly_rsync: $ntfs_friendly_rsync"
require_var src
info "src:  $src"
require_var dest
info "dest: $dest"

[ -e "$dest" ] && info "dest already exists"
[ -d "$dest" ] && info "dest is a directory"

rsync_command=(rsync)
if flag_is_set ntfs_friendly_rsync;
then
    rsync_command+=(-rltDixv)
else
    rsync_command+=(-aHAXSixv)
fi

flag_is_set test && \
    rsync_command+=(-n)
rsync_command+=(--stats)
flag_is_set directory_structure_only && \
    rsync_command+=(-f"+ */" -f"- *")
flag_is_set numeric_ids && \
    rsync_command+=(--numeric-ids)
flag_is_set update && \
    rsync_command+=(--update)
rsync_command+=(--bwlimit="$rsync_bwlimit")
rsync_command+=(--)
rsync_command+=("$src")
rsync_command+=("$dest")

rsync_command_array_length="${#rsync_command[@]}"
info "rsync_command array length: $rsync_command_array_length"
for (( i=0; i<$rsync_command_array_length; i++ )); do
    info "rsync_command[$i]: ${rsync_command[$i]}"
done

info "calling rsync..."
"${rsync_command[@]}" && \
    info "rsync call completed successfully" || \
        die "rsync call failed. Something went wrong"
