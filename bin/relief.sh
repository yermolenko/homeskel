#/bin/bash
#
#  relief - stop/continue an existing process periodically
#
#  Copyright (C) 2015, 2024 Alexander Yermolenko <yaa.mbox@gmail.com>
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

pid=${1:?pid required}

sleeptime=${2:-240}
worktime=${3:-120}

kill -CONT $pid || exit 1

while true
do
    sleep $worktime && \
        echo "Trying to stop the process ..." && \
        kill -TSTP $pid && \
        sleep $sleeptime && \
        echo "Trying to resume the process ..." && \
        kill -CONT $pid \
            || break
done

echo "Exiting..."
