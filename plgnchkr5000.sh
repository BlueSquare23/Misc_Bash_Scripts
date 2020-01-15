#!/bin/bash
#This script runs a loop which deactivates WordPress 
#plugins 1 by 1.

#Checks if you're root
if [[ `whoami` != root ]]
then
	echo "You must be root to run this script!"
	exit
fi

#Tests if you're in the path to a wordpress install
ls|grep -q wp-config.php
if [[ `echo $?` != 0 ]]
then
	echo "You must run this script from the main directory of a WordPress installation!"
	exit
fi

#echo -n "Username: "
#read username

#Grabs Username from path
username=$(pwd|cut -d'/' -f4)

for plugin in $(runuser $username -c 'wp-cli plugin list|grep active'|awk '{print $1}')
do
	echo -n "Would you like to deactivate $plugin? (y/n): "
	read response
	if [[ $response == 'y' ]]
	then
		echo "Disabling $plugin"
		runuser $username -c "wp-cli plugin deactivate $plugin"
	else 
		echo "Not disabling $plugin"
#		exit
	fi

done

