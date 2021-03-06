#!/bin/bash

# this script runs on boot
# make damn sure it doesn't crash
# if it does, you'll need to reboot the whole robot
# :(

# make sure you run this as root!
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root!" 1>&2
	exit 1
fi

# command-line arguments for hex code
ARGS= --init_ang 0.0 --init_x -400 --init_y -300 --grid_scale 5.0 --grid_size 512 --reg_ang 0.3 --reg_pos 0.3 --waypoints wp_home

# the goal here is to run the main code and watch for completion
# if it crashes, rerun it

DIR=/home/bgreer/PROJECTS/HEX/
GREEN_LED=/sys/class/gpio/gpio17
BLUE_LED=/sys/class/gpio/gpio18
WHITE_LED=/sys/class/gpio/gpio41
BUTTON_1=0 # not assigned
BUTTON_2=/sys/class/gpio/gpio16
BUTTON_3=/sys/class/gpio/gpio20
BUTTON_4=/sys/class/gpio/gpio19

# clear previous log file
rm -f ${DIR}/runlog

tries=0
running=0
done=0

# TODO: set run.sh LED on

while [ ${done} -ne 1 ]; do
	# launch program in background
	tries=$((${tries}+1))
	${DIR}/hex $(ARGS) >> ${DIR}/runlog
	# #? gives the return code, $! gives the pid
	ret=$?
	pid=$!
	echo "Try ${tries} (PID=${pid}) returned exit code ${ret}" >> ${DIR}/runlog

	# if success, we are done!
	if [ ${ret} -eq 0 ]
	then
		done=1
	fi

	# if we've tried too many times, stop
	if [ ${tries} -gt 25 ]
	then
		done=1
	fi
done

#TODO: set run.sh LED off

exit 0
