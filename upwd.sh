#!/bin/bash
#Prints other users' pwds

c=0	#Initialize counter (pts/# starts at 0)
if [ -z "$1" ]		#Options check (one arg means no need for getopts)
then
	users=$(who|grep pts|awk '{print $1}')		#Grabs users list
elif [ $1 = "-u" ] && [ $2 != $USER ]		#Single user mode
then
	users=$2
	c=`who|grep $2|awk '{print $2}'|cut -d '/' -f2`		#Grabs single users pts#
else
	echo "Usage: upwd [-u] [username]"		#Taunt user
fi


for user in $users
do
	if [ `tty|cut -d '/' -f4` -eq $c ]		#Tests if user in users is user running script
	then
		udir=`pwd`
	else
		spid=$(ps -efH | grep pts/$c|egrep -w 'bash|csh|dash|fish|ksh|mksh|tcsh|zsh'|tail -1|awk '{print $2}')		#Grabs pid of user's shell proc
		udir=$(ls -l /proc/$spid/|grep cwd|awk '{print $11}')		#Grabs users cwd from proc data
	fi
        printf "$user\t$udir\n"	
	((c++))	
done
