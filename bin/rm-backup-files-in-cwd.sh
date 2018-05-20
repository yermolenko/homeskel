#!/bin/bash
#
#  rm-backup-files-in-cwd.sh - remove backup files in the working dir
#
#  Copyright (C) 2013 Alexander Yermolenko <yaa.mbox@gmail.com>
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
        find . -type f -and \( -name "*~" \) -exec sh -c "ls \"{}\"" \;
        echo "END OF DRY RUN."
        exit 0
    }

find . -type f -and \( -name "*~" \) -exec sh -c "ls \"{}\" && rm -f \"{}\"" \;
