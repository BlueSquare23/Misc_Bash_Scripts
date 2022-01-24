#!/usr/bin/env bash
# This script starts/stops/restarts a Minecraft server.
# Written by John R., August 2020.
# Github: https://github.com/BlueSquare23

start_command="java -Xmx2048M -Xms2048M -jar server.jar nogui"

START(){
	tmux new-session -d -s MCServer &&
	tmux send -t MCServer $start_command \
			ENTER &&
	echo "Minecraft Server Started"
}

STOP(){
	 tmux kill-session -t MCServer &&
	 echo "Minecraft Server Stopped"
}

case $1 in
	start)
		[[ `tmux list-session 2>&1|awk '{print $1}'` == "MCServer:" ]] &&
			echo "Already Running" &&
			exit ||
			START
		;;	
	stop)
		! [[ `tmux list-session 2>&1|awk '{print $1}'` == "MCServer:" ]] &&
                        echo "Not Currently Running" &&
                        exit ||
			STOP
		;;
	restart)
		[[ `tmux list-session 2>&1|awk '{print $1}'` == "MCServer:" ]] &&
			STOP &&
			START ||
			echo "Not Currently Running"
		;;
	*)
		echo "Usage: ./minecraft_server.sh [start/stop/restart]"
esac
