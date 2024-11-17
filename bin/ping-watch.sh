#!/bin/bash
#
#  ping-watch - log and plot ping response times
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

require_root()
{
    [ "$EUID" -eq 0 ] || die "This program is supposed to be run with superuser privileges"
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

usage()
{
    echo "usage: $0 [--from-where [sshuser@]host] target"
}

while [ "$1" != "" ]; do
    [[ "$1" == --from-where ]] && shift && from_where="${1:?Bad host specification}" && shift && continue

    [[ "$1" == -h || "$1" == --help ]] && usage && exit
    [[ "$1" == -* ]] && usage && exit

    var_is_declared target || { target="$1" && shift && continue; }

    shift
done

var_is_declared target || die "target is required"

# var_is_declared from_where && echo "from_where: $from_where"
# if var_is_declared from_where;
# then
#     echo "from_where: $from_where"
# fi
# echo "target: $target"

require ping

var_is_declared from_where && {
    ssh "$from_where" hostname >/dev/null 2>&1 || die "Cannot run commands as ssh $from_where"
    main_command+=(ssh "$from_where")
}
main_command+=(ping -q -c5 -i1 -n -W1 "$target")

dataset_id="ping-$target-from-${from_where:-localhost}"

datafile="$dataset_id.dat"
pltfile="$dataset_id.plt"

read -d '' pltfile_contents <<EOF
#!/usr/bin/gnuplot
#!/usr/bin/gnuplot -p

reset

set grid

# set yrange [:4000]
# set ytics (10,100,1000,10000)

set logscale y 2

set xdata time
set timefmt "%Y-%m-%d %H:%M:%S"

# set xrange ["2020-01-04 08:33:33":]

plot \
     './$datafile' using 1:3 notitle with lines

pause -1 "Press ENTER to exit"
EOF

echo "$pltfile_contents" > "$pltfile"

while true
do
    rtt=`"${main_command[@]}" 2>&1 | awk -F'/' 'END{ print (/^rtt/? $5:"1000000") }'`
    echo "$(date "+%Y-%m-%d %H:%M:%S") $rtt" >> "$datafile"
    sleep 60
done

# "${main_command[@]}" \
#     > >(tee --output-error=warn "$stdout_file") 2> >(tee --output-error=warn "$stderr_file" >&2)
