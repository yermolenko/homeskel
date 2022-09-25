#!/bin/bash
#
#  kb-setup-common.sh - common routines for keyboard setup
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

kb_reset()
{
    killall xcape 2>/dev/null

    setxkbmap \
        -model pc105 \
        -layout us \
        -option ''

    sleep 2
}

#
# Make the space bar work as an additional ctrl key when held
# See man 1 xcape for details
#
space_as_control()
{
    require xmodmap
    require xcape

    killall xcape 2>/dev/null

    spare_modifier="Hyper_L"
    xmodmap -e "keycode 65 = $spare_modifier"
    xmodmap -e "remove mod4 = $spare_modifier"

    xmodmap -e "add Control = $spare_modifier"

    xmodmap -e "keycode any = space"

    xcape -e "$spare_modifier=space"
}

kb_us_ru()
{
    setxkbmap \
        -layout "us,ru" \
        -variant "," \
        -option "grp:shifts_toggle,compose:menu,lv3:rwin_switch,ctrl:nocaps"
}

kb_us_altgr_intl()
{
    setxkbmap \
        -model pc105 \
        -layout us \
        -variant altgr-intl \
        -option 'ctrl:nocaps'
}

kb_us_intl()
{
    setxkbmap \
        -model pc105 \
        -layout us \
        -variant intl \
        -option 'ctrl:nocaps'
}

kb_us_gr()
{
    setxkbmap \
        -layout "us,gr" \
        -variant "," \
        -option "grp:shifts_toggle,compose:menu,lv3:rwin_switch,ctrl:nocaps"
}

kb_pl()
{
    setxkbmap \
        -layout pl \
        -option ""
}

kb_us_ua_unicode()
{
    setxkbmap \
        -layout "us,ua" \
        -variant ",unicode" \
        -option "grp:shifts_toggle,compose:menu,lv3:rwin_switch,ctrl:nocaps"
}

kb_us_ua_unicode_caps_toggle()
{
    setxkbmap \
        -layout "us,ua" \
        -variant ",unicode" \
        -option "grp:caps_toggle,compose:menu,lv3:rwin_switch"
}

# echo "kb-setup-common.sh is a library"
