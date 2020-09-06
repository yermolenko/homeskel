#!/bin/bash
#
#  kb-us-gr.sh - setup keyboard for English/Greek using setxkbmap
#
#  Copyright (C) 2013, 2017, 2019 Alexander Yermolenko
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

require setxkbmap
require kb-spc2ctrl.sh

setxkbmap \
    -model pc105 \
    -layout us \
    -option ''
sleep 2
setxkbmap \
    -layout "us,gr" \
    -variant "," \
    -option "grp:caps_toggle,compose:menu,lv3:rwin_switch"

kb-spc2ctrl.sh
