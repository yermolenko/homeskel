#!/bin/bash
#
#  ytdl-batch-to-dir - convenient downloading of videos
#
#  Copyright (C) 2014, 2017, 2021, 2022, 2023, 2025 Alexander Yermolenko
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

# ! touch "$scriptdir/powned.txt" > /dev/null 2>&1 || die "The script can escape the sandbox"

# hostname=$( hostname )
# if [ "x$hostname" != "xdownloader" ]
# then
#    die "Running youtube-dl on this host is undesired"
# fi

# minimum free disk space (in KiB)
min_free_disk_space=1000000

usage()
{
    echo "usage: $0 [[--audio-only] | [--hd] | [--worst]] [--max-duration <seconds>] [--interactive] [[--use-tor] | [--proxy <proxy>]] ytdl_batch_file [output_dir]"
}

audio_only=0
sd=0
hd=0
worst=0
max_duration=5832
interactive=0

while [ "$1" != "" ]; do
    [[ "$1" == --audio-only ]] && audio_only=1 && shift && continue
    [[ "$1" == --hd ]] && hd=1 && shift && continue
    [[ "$1" == --worst ]] && worst=1 && shift && continue
    [[ "$1" == --max-duration ]] && shift && max_duration="${1:?Bad duration specification}" && shift && continue
    [[ "$1" == --interactive ]] && interactive=1 && shift && continue
    [[ "$1" == --use-tor ]] && proxy=socks5://127.0.0.1:9050/ && shift && continue
    [[ "$1" == --proxy ]] && shift && proxy="${1:?Bad proxy specification}" && shift && continue

    [[ "$1" == -h || "$1" == --help ]] && usage && exit
    [[ "$1" == -* ]] && usage && exit

    var_is_declared batch_file || { batch_file="$1" && shift && continue; }
    var_is_declared output_dir || { output_dir="$1" && shift && continue; }

    shift
done

var_is_declared batch_file || die "ytdl batch filename is required"
var_is_declared output_dir || output_dir=`pwd`

var_is_declared proxy && echo "proxy: $proxy"
# if var_is_declared proxy;
# then
#     echo "proxy: $proxy"
# fi

[ $(( audio_only + sd + hd + worst )) -gt 1 ] && die "Ambiguous output format specification"
[ $(( audio_only + sd + hd + worst )) -eq 0 ] && sd=1
echo "audio_only: $audio_only"
echo "sd: $sd"
echo "hd: $hd"
echo "worst: $worst"

echo "max_duration: $max_duration"
echo "interactive: $interactive"

[ -f "$batch_file" ] || die "Cannot read batch_file: $batch_file"
echo "batch_file: $batch_file"

mkdir -p "$output_dir" > /dev/null 2>&1
output_dir="$(cd "$(dirname -- "$output_dir")" >/dev/null; pwd -P)/$(basename -- "$output_dir")"
echo "output_dir: $output_dir"

[ $audio_only -eq 1 ] && require ffmpeg

ytdl_executable=./youtube-dl
[ -f "$ytdl_executable" ] || ytdl_executable="$scriptdir/youtube-dl"
[ -f "$ytdl_executable" ] || { ytdl_executable=$(which youtube-dl); require youtube-dl; }

echo "ytdl_executable: $ytdl_executable"

urls=()

while IFS= read -r url; do
    urls+=("$url")
done < <(
    cat "$batch_file"
)

mkdir -p "$output_dir/.cache" > /dev/null 2>&1

cd "$output_dir" || die "Cannot cd to the directory"

free_disk_space=$(( $(df -k "$output_dir" | awk 'NR==2 {print $4}') ))
echo "$free_disk_space" > "$output_dir/df-k.txt"
# [ $free_disk_space -lt $min_free_disk_space ] && info "Free disk space is low: $free_disk_space KiB" && exit 0
[ $free_disk_space -lt $min_free_disk_space ] && \
    die "Free disk space is low: $free_disk_space KiB, should be at least $min_free_disk_space KiB"

stdout_file="$output_dir/ytdl-stdout.txt"
stderr_file="$output_dir/ytdl-stderr.txt"

[ -f "$stdout_file" ] && rm "$stdout_file"
[ -f "$stderr_file" ] && rm "$stderr_file"

failed_downloads_file="$output_dir/ytdl-failed-list.txt"

[ -f "$failed_downloads_file" ] && rm "$failed_downloads_file"

excluded_downloads_file="$output_dir/ytdl-excluded-list.txt"

[ -f "$excluded_downloads_file" ] && rm "$excluded_downloads_file"

ytdl_command_base=()
#ytdl_command_base+=(/usr/bin/python3)
ytdl_command_base+=("$ytdl_executable")
var_is_declared proxy && \
    ytdl_command_base+=(--proxy "$proxy")
ytdl_command_base+=(--ignore-errors)
ytdl_command_base+=(--cache-dir "$output_dir/.cache")

for url in "${urls[@]}"
do
    ytdl_command_get_info=("${ytdl_command_base[@]}")
    ytdl_command_get_info+=(--simulate)
    ytdl_command_get_info+=(--print duration)
    ytdl_command_get_info+=(--print title)

    ytdl_command_get_info+=(-- "$url")

    sleep 5

    {
        read -r duration && read -r title || \
                {
                    info "read exit code: $?"
                    printf "%s\n" "$url" >> "$failed_downloads_file"
                    duration=100000
                    continue
                }
    } < <("${ytdl_command_get_info[@]}")

    info "$url duration: $duration"
    info "$url title: $title"

    [ $duration -gt "$max_duration" ] && \
        {
            info "The video \"$url\" is too long. Excluding"
            printf "%s\n" "$url" >> "$excluded_downloads_file"
            continue
        }

    [ $interactive -eq 1 ] && \
        {
            echo -n "Checking the terminal ..." >&2 && [ -t 0 -a -t 2 ] && echo " OK" >&2 && \
                read -p "Do you want to download this video? " -n 1 && \
                [[ $REPLY =~ ^[Yy]$ ]] && echo >&2 || \
                {
                    echo " Excluding the video" >&2;
                    printf "%s\n" "$url" >> "$excluded_downloads_file"
                    continue;
                }

            # echo ""
            echo " Downloading the video ... "
        }

    ytdl_command=("${ytdl_command_base[@]}")
    [ $audio_only -eq 1 ] && \
        ytdl_command+=(--extract-audio --audio-format mp3 --audio-quality 256K)
    [ $hd -eq 1 ] && \
        ytdl_command+=(--format 'mp4[height<=720]/bestvideo[height<=720]+mp4/bestaudio/best')
    [ $sd -eq 1 ] && \
        ytdl_command+=(--format 'mp4[height<=480]/bestvideo[height<=480]+mp4/bestaudio/best')
    [ $worst -eq 1 ] && \
        ytdl_command+=(-S +size,+br,+res,+fps)
    ytdl_command+=(--output "%(upload_date)s-%(id)s.mp4")
    ytdl_command+=(--restrict-filenames)
    ytdl_command+=(--write-description)
    ytdl_command+=(--write-info-json)

    ytdl_command+=(-- "$url")

    printf "==========\n%s\n" "$url" >> "$stdout_file"
    printf "==========\n%s\n" "$url" >> "$stderr_file"

    # ytdl_command_array_length="${#ytdl_command[@]}"
    # info "ytdl_command array length: $ytdl_command_array_length"
    # for (( i=0; i<$ytdl_command_array_length; i++ )); do
    #     info "ytdl_command[$i]: ${ytdl_command[$i]}"
    # done

    sleep 5

    "${ytdl_command[@]}" \
        >> "$stdout_file" 2>> "$stderr_file" || \
        printf "%s\n" "$url" >> "$failed_downloads_file"
done

touch "$output_dir/.updated.txt" || die "Cannot touch directory update flag"

# --output "%(id)s-%(upload_date)s.mp4" \
# --output "%(id)s-%(upload_date)s-%(release_date)s.mp4" \
# --output "%(autonumber)s.mp4" \

# --format 'mp4[height<=480]+mp4[height<=480]' \
# --format 'mp4/bestvideo[height<=480]+mp4/bestaudio/best[height<=480]' \
# --output "%(title)s-%(id)s.%(ext)s" \

# --force-ipv6

# --format 'bestvideo[height<=720]+bestaudio/best[height<=720]' \
# --format 'bestvideo[height<=480]+bestaudio/best[height<=480]' \
