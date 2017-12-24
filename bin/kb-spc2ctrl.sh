#!/bin/bash
#
# Make the space bar work as an additional ctrl key when held
# See man 1 xcape for details
#

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

require xmodmap
require xcape

killall xcape 2>/dev/null

# First,  map  an  unused  modifier's keysym to the spacebar's keycode and make it a
# control modifier. It needs to be an existing key so that  emacs  won't  spazz  out
# when you press it. Hyper_L is a good candidate.

spare_modifier="Hyper_L"
xmodmap -e "keycode 65 = $spare_modifier"
xmodmap -e "remove mod4 = $spare_modifier"
# hyper_l is mod4 by default
xmodmap -e "add Control = $spare_modifier"

# Next, map space to an unused keycode (to keep it around for xcape to use).

xmodmap -e "keycode any = space"

# Finally use xcape to cause the space bar to generate a space when tapped.

xcape -e "$spare_modifier=space"
