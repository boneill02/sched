#!/bin/sh

[ -z "$BLOCKFILE" ] && BLOCKFILE="blocks.txt"
[ -z "$TIMESFILE" ] && TIMESFILE="times.txt"

SCHEDULE="A"

do_sched_times() { \
	for day in $(seq 5); do
		echo "$day:" >> "$TIMESFILE"
		echo "How many blocks do you have on $day?"
		read RES
		for num in $(seq $RES); do
			echo "When does block $num start?"
			read RES
			echo -n "$num,$RES," >> "$TIMESFILE"
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

	echo "How many blocks do you have?"
	read RES
	for num in $(seq $RES); do
		echo "What days does block $num occur? (format: MTWHF, H being Thursday)"
		read RES
		echo "$num:$RES" >> "$BLOCKFILE"
	done
}

do_sched_get() { \
	day="$(date "+%u")"
	time="$(date "+%H:%M")"

	echo "What schedule?"
	read SCHEDULE
	BLOCKFILE="blocks$SCHEDULE.txt"
	TIMESFILE="times$SCHEDULE.txt"

	echo "$(grep "$day" "$TIMESFILE" | )"
}

[ -z "$1" ] && do_sched_get && exit
[ -e "$1" "setup" ] && do_sched_blocks && do_sched_times && exit
