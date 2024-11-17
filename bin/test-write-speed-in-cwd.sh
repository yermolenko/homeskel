#!/bin/bash
#
#  test-write-speed-in-cwd - determine effective file write speed in
#  the current working directory
#
#  Copyright (C) 2024 Alexander Yermolenko <yaa.mbox@gmail.com>
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

maxbs_kb="${1:-10000}"
maxbs_count="${2:-10}"
minbs_kb="${3:-100}"
data_source="${4:-/dev/zero}"

die()
{
    local msg=${1:-"Unknown error"}
    shift
    echo "ERROR: $msg $@" 1>&2
    exit 1
}

info()
{
    local msg=${1:-"Unspecified message"}
    shift
    echo "INFO: $msg $@" 1>&2
}

call_sync()
{
    info "running \"time sync\" ..."
    time sync --file-system ./
}

run_test()
{
    local bs_kb="$maxbs_kb"
    local bs_count="$maxbs_count"

    call_sync

    while true
    do
        info " "
        info "========== ${bs_kb}K * $bs_count ${extra_dd_options[@]} =========="

        dd if="$data_source" of="$test_filename" \
           "${extra_dd_options[@]}" \
           bs=${bs_kb}K count=${bs_count} \
            || die "dd call failed"

        call_sync

        rm "$test_filename"

        bs_kb=$(( $bs_kb / 10 ))
        bs_count=$(( $bs_count * 10 ))

        [ $bs_kb -lt $minbs_kb ] && break
    done
}

[ $maxbs_kb -gt 0 ] || die "maxbs_kb ($maxbs_kb) is not a positive number"
[ $maxbs_count -gt 0 ] || die "maxbs_count ($maxbs_count) is not a positive number"
[ $minbs_kb -gt 0 ] || die "minbs_kb ($minbs_kb) is not a positive number"
[ $minbs_kb -le $maxbs_kb ] || die "minbs_kb ($minbs_kb) > maxbs_kb ($maxbs_kb)"

date=`date "+%Y%m%d-%H%M%S"`

test_filename="./test-write-speed-$date.dat"

extra_dd_options=()
extra_dd_options+=(conv=fdatasync)
run_test

extra_dd_options=()
extra_dd_options+=(conv=fdatasync)
extra_dd_options+=(oflag=dsync)
run_test

# extra_dd_options=()
# extra_dd_options+=(oflag=dsync)
# run_test

extra_dd_options=()
run_test
