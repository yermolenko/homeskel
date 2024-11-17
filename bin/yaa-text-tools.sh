#!/bin/bash
#
#  yaa-text-tools.sh - various text manipulation tools
#
#  Copyright (C) 2021, 2022, 2023, 2024 Alexander Yermolenko
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

romanize_as_russian()
{
    cat | \
        sed 's/Бе/Bie/g; s/Ве/Vie/g; s/Ге/Gie/g; s/Де/Die/g;' | \
        sed 's/Же/Zhie/g; s/Зе/Zie/g; s/Ке/Kie/g; s/Ле/Lie/g;' | \
        sed 's/Ме/Mie/g; s/Не/Nie/g; s/Пе/Pie/g; s/Ре/Rie/g;' | \
        sed 's/Се/Sie/g; s/Те/Tie/g; s/Фе/Fie/g; s/Хе/Khie/g;' | \
        sed 's/Це/Tsie/g; s/Че/Chie/g; s/Ше/Shie/g; s/Ще/Shchie/g;' | \
        sed 's/Бё/Bio/g; s/Вё/Vio/g; s/Гё/Gio/g; s/Дё/Dio/g;' | \
        sed 's/Жё/Zhio/g; s/Зё/Zio/g; s/Кё/Kio/g; s/Лё/Lio/g;' | \
        sed 's/Мё/Mio/g; s/Нё/Nio/g; s/Пё/Pio/g; s/Рё/Rio/g;' | \
        sed 's/Сё/Sio/g; s/Тё/Tio/g; s/Фё/Fio/g; s/Хё/Khio/g;' | \
        sed 's/Цё/Tsio/g; s/Чё/Chio/g; s/Шё/Shio/g; s/Щё/Shchio/g;' | \
        sed 's/Бю/Biu/g; s/Вю/Viu/g; s/Гю/Giu/g; s/Дю/Diu/g;' | \
        sed 's/Жю/Zhiu/g; s/Зю/Ziu/g; s/Кю/Kiu/g; s/Лю/Liu/g;' | \
        sed 's/Мю/Miu/g; s/Ню/Niu/g; s/Пю/Piu/g; s/Рю/Riu/g;' | \
        sed 's/Сю/Siu/g; s/Тю/Tiu/g; s/Фю/Fiu/g; s/Хю/Khiu/g;' | \
        sed 's/Цю/Tsiu/g; s/Чю/Chiu/g; s/Шю/Shiu/g; s/Щю/Shchiu/g;' | \
        sed 's/Бя/Bia/g; s/Вя/Via/g; s/Гя/Gia/g; s/Дя/Dia/g;' | \
        sed 's/Жя/Zhia/g; s/Зя/Zia/g; s/Кя/Kia/g; s/Ля/Lia/g;' | \
        sed 's/Мя/Mia/g; s/Ня/Nia/g; s/Пя/Pia/g; s/Ря/Ria/g;' | \
        sed 's/Ся/Sia/g; s/Тя/Tia/g; s/Фя/Fia/g; s/Хя/Khia/g;' | \
        sed 's/Ця/Tsia/g; s/Чя/Chia/g; s/Шя/Shia/g; s/Щя/Shchia/g;' | \
        sed 's/бе/bie/g; s/ве/vie/g; s/ге/gie/g; s/де/die/g;' | \
        sed 's/же/zhie/g; s/зе/zie/g; s/ке/kie/g; s/ле/lie/g;' | \
        sed 's/ме/mie/g; s/не/nie/g; s/пе/pie/g; s/ре/rie/g;' | \
        sed 's/се/sie/g; s/те/tie/g; s/фе/fie/g; s/хе/khie/g;' | \
        sed 's/це/tsie/g; s/че/chie/g; s/ше/shie/g; s/ще/shchie/g;' | \
        sed 's/бё/bio/g; s/вё/vio/g; s/гё/gio/g; s/дё/dio/g;' | \
        sed 's/жё/zhio/g; s/зё/zio/g; s/кё/kio/g; s/лё/lio/g;' | \
        sed 's/мё/mio/g; s/нё/nio/g; s/пё/pio/g; s/рё/rio/g;' | \
        sed 's/сё/sio/g; s/тё/tio/g; s/фё/fio/g; s/хё/khio/g;' | \
        sed 's/цё/tsio/g; s/чё/chio/g; s/шё/shio/g; s/щё/shchio/g;' | \
        sed 's/бю/biu/g; s/вю/viu/g; s/гю/giu/g; s/дю/diu/g;' | \
        sed 's/жю/zhiu/g; s/зю/ziu/g; s/кю/kiu/g; s/лю/liu/g;' | \
        sed 's/мю/miu/g; s/ню/niu/g; s/пю/piu/g; s/рю/riu/g;' | \
        sed 's/сю/siu/g; s/тю/tiu/g; s/фю/fiu/g; s/хю/khiu/g;' | \
        sed 's/цю/tsiu/g; s/чю/chiu/g; s/шю/shiu/g; s/щю/shchiu/g;' | \
        sed 's/бя/bia/g; s/вя/via/g; s/гя/gia/g; s/дя/dia/g;' | \
        sed 's/жя/zhia/g; s/зя/zia/g; s/кя/kia/g; s/ля/lia/g;' | \
        sed 's/мя/mia/g; s/ня/nia/g; s/пя/pia/g; s/ря/ria/g;' | \
        sed 's/ся/sia/g; s/тя/tia/g; s/фя/fia/g; s/хя/khia/g;' | \
        sed 's/ця/tsia/g; s/чя/chia/g; s/шя/shia/g; s/щя/shchia/g;' | \
        sed 's/е/ye/g; s/ё/yo/g; s/є/ye/g; s/ж/zh/g; s/ї/yi/g; s/х/kh/g; s/ц/ts/g; s/ч/ch/g; s/ш/sh/g; s/щ/shch/g; s/[ьъ]//g; s/ю/yu/g; s/я/ya/g' | \
        sed 's/Е/Ye/g; s/Ё/Yo/g; s/Є/Ye/g; s/Ж/Zh/g; s/Ї/Yi/g; s/Х/Kh/g; s/Ц/Ts/g; s/Ч/Ch/g; s/Ш/Sh/g; s/Щ/Shch/g; s/[ЬЪ]//g; s/Ю/Yu/g; s/Я/Ya/g' | \
        sed 'y/абвгґдзиійклмнопрстуўфыэ/abvggdziiyklmnoprstuvfye/' | \
        sed 'y/АБВГҐДЗИІЙКЛМНОПРСТУЎФЫЭ/ABVGGDZIIYKLMNOPRSTUVFYE/'
}

romanize()
{
    romanize_as_russian
}

sanitize_generic()
{
    tr -cd '[:alnum:]._\- '
}

sanitize_for_windows_filename()
{
    tr -d '[:cntrl:]' | \
        sed -E 'y/:/-/' | \
        sed -E 's/^\s*//' | \
        sed -E 's/\s*$//' | \
        sed -E 's/\.+$//g' | \
        tr -d '*"<>|\\\/\n\?'
}

sanitize_for_pretty_filename()
{
    sanitize_for_windows_filename | \
        sed -E 's/\s+\././g' | \
        sed -E "s/'//g" | \
        tr -d '[]'
}

sanitize_for_m3u_title()
{
    LANG=en_US.UTF-8 sed -e "s/[^ _a-zA-Zа-яА-Я0-9\,\.\-]//g" -e 's/ \+/ /'
}

urlencode()
{
    require jq
    jq -sRr @uri
}

urlencode_path()
{
    local string="${1:?pathname is required}"
    string="$( printf %s "$string" | urlencode )"
    string=${string//%2F/\/}
    printf %s "$string"
}

# echo "yaa-text-tools.sh is a library"
