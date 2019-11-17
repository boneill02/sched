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
[ -z "$day" ] && day="$(date "+%u")"
[ -z "$now" ] && now="$(date "+%H:%M")"

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

get_schedule() { \
	echo "What schedule?"
	read SCHEDULE
}

do_sched_get() { \
	[ -z "$SCHEDULE" ] && get_schedule
	BLOCKFILE="blocks$SCHEDULE.txt"
	TIMESFILE="times$SCHEDULE.txt"
	NAMESFILE="names$SCHEDULE.txt"
	day_content="$(sed "/^$day:$/,/^$(echo "$day+1" | bc)$:/p" "$TIMESFILE" | uniq | sed "1d")"
	for block in $(echo "$day_content" | tr '\n' ' '); do
		time="$(echo "$block" | sed 's/.*,//')"
		for time in "$(echo "$block" | tr '\n' ' ' | sed 's/.*,//')"; do
			start_time="$(echo "$time" | sed 's/-.*//')"
			end_time="$(echo "$time" | sed 's/.*-//')"
			[ -z "$1" ] && $(datetest "$now" --ge "$start_time") && $(datetest "$now" --lt "$end_time") && \
				echo "$(echo "$block" | sed 's/,.*//g' | ed -s "$NAMESFILE")" && return

			[ "$1" = "next" ] && $(datetest "$now" --ge "$start_time") && \
				$(datetest "$now" --lt "$end_time") && echo "$(echo "$block" \
				| sed 's/,.*/+1/g' | bc | ed -s "$NAMESFILE")" && return
		done
	done
	echo "Nothing slotted here!"
}

[ "$1" = "setup" ] && do_sched_blocks && do_sched_times && do_sched_names && exit
[ "$1" = "next" ] && do_sched_get "next" && exit
[ -z "$1" ] && do_sched_get && exit
