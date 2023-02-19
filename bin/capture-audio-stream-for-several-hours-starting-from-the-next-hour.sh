#!/bin/bash
#
#  capture-audio-stream.sh - capture audio stream for several hours
#  starting from the next hour
#
#  Copyright (C) 2023 Alexander Yermolenko <yaa.mbox@gmail.com>
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

require capture-audio-stream.sh

stream_url="${1:?Stream URL is required}"
number_of_hours="${2:-8}"
recording_id="${3:-streamname-hour}"

next_hour_date=`date +"%Y-%m-%d %H:00:00" --date="+ 1hour"`

info "Scheduling capture of $stream_url starting from $next_hour_date for $number_of_hours hours"

capture-audio-stream.sh "$stream_url" "1:00:00" "$next_hour_date" "$recording_id" "$number_of_hours" 3600
