#!/usr/bin/env bash
# This script prints the only the last x minutes of a log file.
# Only works on log files that have the time formatted, 'HH:MM:'
# Written by, John R. Github: https://www.bluesquare23.sh

trap exit SIGINT

 [ -z $1 ] || [ -z $2 ] && echo "Usage: lastxmin.sh [Number of Minutes] [Log File]" && exit

# Tolerate BSD
 [[ -e `which gdate` ]] && shopt -s expand_aliases && alias date="gdate"

numMin=$1
logFile=$2

epoc=`date +%s`
epocMinusXMin=$(($epoc - $(($numMin * 60))))

xMinutesAgo=`date +%R --date="@$epocMinusXMin"|cut -d: -f2`
xHoursAgo=`date +%R --date="@$epocMinusXMin"|cut -d: -f1`
curMin=`date +%M`
curHour=`date +%H`

if ! [[ $xHoursAgo -eq $curHour ]]
then
	for hour in `seq $xHoursAgo $curHour`
	do 
		printf -v hour "%02d" $hour
		if [[ $hour -eq $xHoursAgo ]]
		then
			for min in `seq $xMinutesAgo 59`
			do
				printf -v min "%02d" $min
#				echo "$hour:$min:"
				grep -a "$hour:$min:" $logFile
			done
		elif [[ $hour -eq $curHour ]]
		then
			for min in `seq 00 $curMin`
			do 
				printf -v min "%02d" $min
#				echo "$hour:$min:"
				grep -a "$hour:$min:" $logFile
			done
		else
			for min in `seq 00 59`
			do 
				printf -v min "%02d" $min
#				echo "$hour:$min:" 
				grep -a "$hour:$min:" $logFile
			done
		fi
	done
fi


if [[ $xHoursAgo -eq $curHour ]]
then
	for min in `seq $xMinutesAgo $curMin`
	do 
		printf -v min "%02d" $min
#		echo "$curHour:$min:"
		grep -a "$curHour:$min:" $logFile
	done
fi
