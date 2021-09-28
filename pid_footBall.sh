#!/usr/bin/env bash
## Football: Testing With Multiple Signals
# Thows a PID footBall back and forth. Warning!!! This script will just run in
# the background ad-infinitum unless stopped.
# Written by John R., Sept 2021

script_name=`basename "$0"`

# The catchAndReturn() function sets up a while loop with a timeout of ~5
# seconds that contains a trap signal. The trap signal is setup to listen for
# SIGUSR1 aka kill -10. If it gets this signal while running, the trap will
# echo the message below into file.log and then call this script, in the
# background, in throwBall mode, triggering throwBall(), starting the cycle all
# over again. 

# If this script is started normally, catchAndReturn() is the third function
# triggered. In our example, Team 1 is catching -- its their trap signal. If
# Team 1 catches a SIGUSR1 footBall first they'll log that they caught it, then
# log that they're going to throw it, and then finally trigger the script in
# throwBall mode to Team 2.

function catchAndReturn(){
	[[ $1 -eq 1 ]] && toTeamNum=2 || toTeamNum=1
	t=0
	while [[ $t -le 5 ]] 
	do
		trap "echo 'Team $1 caught footBall' >> file.log && sleep 1 && echo 'Team $1 throwing footBall' >> file.log && ./$script_name throwBall $toTeamNum && exit" SIGUSR1
		sleep 1
		((t++))
	done
}

# The throwBall() function does two does two things. First it calls this script
# in catchAndReturn mode in the background setting up the trap listener. In the
# context of the footBall metaphor consider this like giving the other team a
# heads up that you're going to throw the ball to them. At least I think that's
# how footBall works? I don't know, this is about signals in bash. 

# When called in normal start mode, throwBall() is the function triggered right
# after coinToss(). In our example, throwBall() is called with $1 equal to 1,
# because we're throwing the ball to Team 1. So throwBall() forks and runs
# this script in the background in catchAndReturn mode then signals that fork
# and exits.

function throwBall(){
	./$script_name catchAndReturn $1 &
	export ListenerPid=$!
	sleep 1
	kill -10 $ListenerPid
	unset ListenerPid
	exit
}

# The coinToss() function takes advantage of the bash $RANDOM variable to flip
# a coin. That coinToss is used to decide who the ball is thrown to first. For
# the sake of example, lets say the ball was thrown to Team 1 first, aka
# throwBall 1.

function coinToss(){
	[[ $(($(($RANDOM%10))%2)) -eq 1 ]] && throwBall 1 || throwBall 2
}

# cleanUp() removes the logFile and kills the background shell processes.

function cleanUp(){
	rm file.log
	kill -9 `pgrep -f "$script_name"`
}

# For human input
[[ $1 = 'start' ]] && coinToss
[[ $1 = 'stop' ]] && cleanUp
[[ $1 = 'follow' ]] && tail -f file.log

# Not for human input
[[ $1 = 'catchAndReturn' ]] && [[ $2 -eq 1 ]] && catchAndReturn 1
[[ $1 = 'catchAndReturn' ]] && [[ $2 -eq 2 ]] && catchAndReturn 2
[[ $1 = 'throwBall' ]] && [[ $2 -eq 1 ]] && throwBall 1
[[ $1 = 'throwBall' ]] && [[ $2 -eq 2 ]] && throwBall 2

echo "Usage: pid_footBall.sh [start/stop/follow]"

# If you'd like to manually spark the engine you can run:
#
#	./pid_footBall.sh catchAndReturn 1 & 
#
# And then within the 5 second timeout of catchAndReturn() run:
#
#	kill -10 $!
#
# Then you can follow the running exchange with:
#
#	./pid_footBall.sh follow
