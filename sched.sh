#!/bin/sh
# Copyright (C) 2019 Ben O'Neill <ben@benoneill.xyz>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

[ -z "$BLOCKFILE" ] && BLOCKFILE="blocks.txt"
[ -z "$TIMESFILE" ] && TIMESFILE="times.txt"
[ -z "$NAMESFILE" ] && NAMESFILE="names.txt"

SCHEDULE="A"

do_sched_times() { \
	for day in $(seq 5); do
		echo "$day:" >> "$TIMESFILE"
		echo "How many blocks do you have on $day?"
		read RES
		for num in $(seq $RES); do
			echo "When does block $num start?"
			read RES
			echo -n "$num,$RES-" >> "$TIMESFILE"
			echo "When does block $num end?"
			echo "$RES" >> "$TIMESFILE"
		done
	done
}

do_sched_blocks() { \
	echo "Name the schedule:"
	read SCHEDULE
	BLOCKFILE="blocks$SCHEDULE.txt"
	TIMESFILE="times$SCHEDULE.txt"
	NAMEFILE="blocks$SCHEDULE.txt"

	echo "How many blocks do you have?"
	read RES
	for num in $(seq $RES); do
		echo "What is the name of block $num?"
		read RES
		echo "$RES" >> "$NAMEFILE"
		echo "What days does block $num occur? (format: MTWHF, H being Thursday)"
		read RES
		echo "$num:$RES" >> "$BLOCKFILE"
	done
}

do_sched_get() { \
	day="$(date "+%u")"
	now="$(date "+%H:%M")"

	echo "What schedule?"
	read SCHEDULE
	BLOCKFILE="blocks$SCHEDULE.txt"
	TIMESFILE="times$SCHEDULE.txt"
	NAMESFILE="names$SCHEDULE.txt"

	day_content="$(sed "/^$day:/,/^$(echo "$day+1" | bc):/p;" "$TIMESFILE" | sed "s/^$day://" | uniq)"
	for block in $(echo "$day_content" | tr '\n' ' '); do
		time="$(echo "$block" | sed 's/.*,//')"
		for time in "$(echo "$block" | tr '\n' ' ')"; do
			start_time="$(echo "$time" | sed 's/.*,//;s/-.*//')"
			end_time="$(echo "$time" | sed 's/.*,//;s/.*-//')"
			$(datetest "$now" --ge "$start_time") && $(datetest "$now" --lt "$end_time") && \
				echo "$(echo "$block" | sed 's/,.*/p/g' | ed -s "$NAMESFILE")" && return
		done
	done
	echo "Nothing slotted here!"
}

[ "$1" = "setup" ] && do_sched_blocks && do_sched_times && do_sched_names && exit
[ -z "$1" ] && do_sched_get && exit
