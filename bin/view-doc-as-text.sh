#!/bin/bash
#
#  view-doc-as-text - view text-containing files as plain text
#
#  Copyright (C) 2014, 2017, 2022 Alexander Yermolenko
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

f1=${1:?Filename is required}
editor=${2:-cat}

die()
{
    local msg=${1:-"Unknown error"}
    hash zenity 2>/dev/null && \
        zenity --error --title "Error" --text "ERROR: $msg"
    echo "ERROR: $msg" 1>&2
    exit 1
}

goodbye()
{
    local msg=${1:-"Cancelled by user"}
    hash zenity 2>/dev/null && \
        zenity --warning --title "Goodbye!" --text "$msg"
    echo "INFO: $msg" 1>&2
    exit 1
}

require()
{
    local cmd=${1:?"Command name is required"}
    local extra_info=${2:+"\nNote: $2"}
    hash $cmd 2>/dev/null || die "$cmd not found$extra_info"
}

require xdg-mime "xdg-utils package"

tempdir=$( mktemp -d )
[ -d "$tempdir" ] || die "Temp dir has not been created."

view_via_antiword()
{
    local f1orig=${1:?"Filename is required"}

    local f1wodir="1-$( basename "$f1" )"

    local f1="$tempdir/$f1wodir"

    cp "$f1orig" "$f1" || die "Cannot copy first file"

    local f1doc="$tempdir/${f1wodir%.*}.doc"

    require soffice "LibreOffice"

    [ -f "$f1doc" ] \
        || soffice --headless --convert-to doc --outdir "$tempdir" "$f1" >/dev/null 2>&1

    [ -f "$f1doc" ] || die "Cannot find first converted file : $f1doc"

    require antiword
    require catdoc

    local f1txt="$f1doc.txt"
    # antiword -w 0 "$f1doc" > "$f1txt" || catdoc "$f1doc" >> "$f1txt"
    antiword -w 0 "$f1doc" > "$f1txt"
    echo "====================== END OF DOCUMENT ======================" >> "$f1txt"
    catdoc "$f1doc" >> "$f1txt"
    chmod ugo-w "$f1txt"
    $editor "$f1txt"
    chmod ugo+w "$f1txt"
    rm "$f1txt" || die "Cannot remove temp files"
}

[ -f "$f1" ] || [ -d "$f1" ] \
    || die "$f1 is not a file/directory or does not exist."

mimetype=$(xdg-mime query filetype "$f1" | sed 's/;.*$//')
if [[ $mimetype == application/msword \
            || $mimetype =~ application/.*ms-word \
            || $mimetype =~ application/.*officedocument \
            || $mimetype =~ application/.*opendocument.text ]]; then
    view_via_antiword "$f1"
else
    die "Cannot determine office file format"
fi
