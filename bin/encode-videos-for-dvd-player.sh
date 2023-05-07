#!/bin/bash
#
#  encode-videos-for-dvd-player.sh - encode recursively found video
#  files for Xvid-capable DVD players
#
#  Copyright (C) 2010, 2023 Alexander Yermolenko <yaa.mbox@gmail.com>
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

require ffmpeg

video_bitrate=1200k
audio_bitrate=192k

usage()
{
    echo "usage: $0 videos_dir [output_dir]"
}

while [ "$1" != "" ]; do
    [[ "$1" == -h || "$1" == --help ]] && usage && exit
    [[ "$1" == -* ]] && usage && exit

    var_is_declared videos_dir || { videos_dir="$1" && shift && continue; }
    var_is_declared output_dir || { output_dir="$1" && shift && continue; }

    shift
done

var_is_declared videos_dir || die "videos_dir is required"
var_is_declared output_dir || output_dir=`pwd`

[ -d "$videos_dir" ] || die "Cannot read directory: $videos_dir"
[ -d "$output_dir" ] || die "Cannot access output directory: $output_dir"

videos_dir="$( cd "$videos_dir" && pwd )"
output_dir="$( cd "$output_dir" && pwd )"

echo "videos_dir: $videos_dir"
echo "output_dir: $output_dir"

[ -d "$videos_dir" ] || die "Cannot read directory: $videos_dir"
[ -d "$output_dir" ] || die "Cannot access output directory: $output_dir"
[ "x$videos_dir" == "x$output_dir" ] && die "input and output directories are the same"

videofiles=()
while IFS= read -r file; do
    videofiles+=("$file")
done < <(
    find -L "$videos_dir" -type f \
         \( -iname \*.mp4 -o -iname \*.avi \
         -o -iname \*.mpg -o -iname \*.mpeg \
         -o -iname \*.mkv -o -iname \*.webm \) \
         -printf '%h/%f\n' | sort -f
)

for videofile in "${videofiles[@]}"
do
    videofile_basename=`basename "$videofile"`
    reencoded_videofile="${videofile_basename%.*}.avi"

    cd "$output_dir" || die "Cannot cd to output dir"

    info "Converting \"$videofile\" to \"$reencoded_videofile\""

    # two-pass Xvid

    ffmpeg -i "$videofile" \
           -vf "scale='min(720,iw)':'min(480,ih)'" \
           -c:v libxvid -b:v "$video_bitrate" \
           -y \
           -pass 1 -an -f avi /dev/null

    ffmpeg -i "$videofile" \
           -vf "scale='min(720,iw)':'min(480,ih)'" \
           -c:v libxvid -b:v "$video_bitrate" \
           -pass 2 \
           -c:a libmp3lame -b:a "$audio_bitrate" \
           "$reencoded_videofile"

    # basic Xvid

    # ffmpeg -i "$videofile" \
    #        -vf "scale='min(720,iw)':'min(480,ih)'" \
    #        -c:v libxvid -b:v "$video_bitrate" \
    #        -c:a libmp3lame -b:a "$audio_bitrate" \
    #        "xvid-1p-$reencoded_videofile"

    # native encoder mpeg4

    # ffmpeg -i "$videofile" \
    #        -vf "scale='min(720,iw)':'min(480,ih)'" \
    #        -c:v mpeg4 -vtag xvid -b:v "$video_bitrate" \
    #        -c:a libmp3lame -b:a "$audio_bitrate" \
    #        "mpeg4-$reencoded_videofile"
done
