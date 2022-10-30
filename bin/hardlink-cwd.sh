#!/bin/bash
#
#  hardlink-cwd.sh - hardlink duplicates in the working dir
#
#  Copyright (C) 2013, 2021, 2022 Alexander Yermolenko
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

date=`date "+%Y%m%d-%H%M%S"`

usage()
{
    echo "usage: $0 [[[--no-test] [--another-option]] | [-h]]"
}

test=1
another_option=0

while [ "$1" != "" ]; do
    case $1 in
        --no-test )
            test=0
            ;;
        --another-option )
            another_option=1
            ;;
        -h | --help )
            usage
            exit
            ;;
        * )
            usage
            exit 1
    esac
    shift
done

[ $test -eq 1 ] && \
    {
        echo "DRY RUN..."
        hardlink --dry-run \
                 --ignore-time \
                 --exclude 'hardlink-*' \
                 ./ \
            && echo "DONE."
        echo "END OF DRY RUN."
        exit 0
    }

echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
    read -p "Are you sure to hardlink duplicates in $PWD recursively? " -n 1 && \
    [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || { echo " Exiting." >&2; exit 1; }

echo ""
echo ""
echo -n "Generating list of duplicates for hardlinking in $PWD recursively ... "

hardlink --dry-run \
         -v \
         --ignore-time \
         --exclude 'hardlink-*' \
         ./ > hardlink-$date.stdout 2> hardlink-$date.stderr \
    && echo "DONE." || exit 1

echo ""
echo "Hardlinking duplicates in $PWD recursively ... "

hardlink \
    --ignore-time \
    --exclude 'hardlink-*' \
    ./ \
    && touch hardlink-$date.ok && echo "DONE." || echo "FAILED."

# --respect-name
