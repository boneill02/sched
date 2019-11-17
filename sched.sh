#!/bin/sh

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

	#debug
	day="1"
	now="1:24"

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
				echo "$(echo "$block" | sed 's/,.*/p/g' | ed -s "$NAMESFILE")"
		done
	done
}

[ "$1" -e "setup" ] && do_sched_blocks && do_sched_times && do_sched_names && exit
[ -z "$1" ] && do_sched_get && exit
