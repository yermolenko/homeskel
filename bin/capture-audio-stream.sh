#!/bin/bash
#
#  capture-audio-stream.sh - capture audio stream
#
#  Copyright (C) 2012, 2023 Alexander Yermolenko <yaa.mbox@gmail.com>
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

require mpv
require lame

stream_url="${1:?Stream URL is required}"
duration="${2:-1:00:00}"
start_date="${3:-`date +"%Y-%m-%d %H:%M:%S"`}"
recording_id="${4:-streamname-hour}"
start_count="${5:-1}"
start_gap="${6:-3600}"

info "stream_url: $stream_url"
info "start_date: $start_date"
info "duration: $duration"
info "recording_id: $recording_id"
info "start_count: $start_count"
info "start_gap: $start_gap seconds"

duration_index=0

while [  $duration_index -lt "$start_count" ];
do
    {
        now_epoch=$(date +%s)
        start_epoch=$(date -d "$start_date" +%s)

        info "#$duration_index: now_epoch: $now_epoch"
        info "#$duration_index: start_epoch: $start_epoch"

        sleep_seconds=$(( $start_epoch - $now_epoch ))
        [  $sleep_seconds -lt 0 ] && \
            sleep_seconds=0 && info "#$duration_index: WARNING: start_date is in the past!"

        info "#$duration_index: Sleeping to the initial start date for $sleep_seconds seconds"
        sleep $sleep_seconds

        sleep_index=0

        while [  $sleep_index -lt "$duration_index" ];
        do
            info "#$duration_index: Sleeping start gap for $start_gap seconds"
            sleep "$start_gap"
            let sleep_index=sleep_index+1
        done

        fname="$recording_id-`date +"%Y%m%d_%H%M%S"`"

        info "#$duration_index: $fname capturing started"

        mpv --length="$duration" --ao=pcm --ao-pcm-file="$fname.wav" \
            --cache-secs=30 --no-config --no-ytdl --quiet \
            "$stream_url" \
            > "$fname.stdout" 2> "$fname.stderr" && \
            {
                {
                    info "#$duration_index: $fname encoding started" && \
                        lame --quiet -h -b 128 "$fname.wav" "$fname.mp3" && \
                        rm "$fname.wav" && \
                        info "#$duration_index: $fname encoding success" || \
                            info "#$duration_index: $fname encoding failed"
                    info "#$duration_index: $fname tags extraction started" && \
                        cat "$fname.stdout" | grep " icy" > "$fname.txt"
                    rm "$fname.stdout"
                    rm "$fname.stderr"
                } &
            }
    } &

    let duration_index=duration_index+1
done

info "Waiting for capture and encoding jobs to finish"

wait

info "All jobs have finished. Exiting"
