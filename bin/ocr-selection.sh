#!/bin/bash

ocr_lang=${1:-rus}

die()
{
    local msg=${1:-"Unknown error"}
    hash zenity 2>/dev/null && \
        zenity --error --title "Error" --text "ERROR: $msg"
    echo "ERROR: $msg" 1>&2
    exit 1
}

require()
{
    local cmd=${1:?"Command name is required"}
    local extra_info=${2:+"\nNote: $2"}
    hash $cmd 2>/dev/null || die "$cmd not found$extra_info"
}

require scrot
require tesseract
require xclip

tempdir=$( mktemp -d )

cd "$tempdir" || die "Cannot cd to temp dir."

scrot --select --silent ./ocr.png || die "scrot error"

tesseract ./ocr.png ./ocr -l "$ocr_lang" || die "tesseract error"

cat ./ocr.txt

cat ./ocr.txt | xclip -selection clipboard

rm ./ocr.png ./ocr.txt

rmdir "$tempdir" || die "Cannot remove temporary directory."
