#!/bin/bash
#This script allows you to request to watch a stream of another users terminal.

#Get options which have been passed
while getopts :hadu: options 
do
        case ${options} in
                h) HELP=1;;
		a) ACCEPT=1;;
		d) DENY=1;;
                u) U=$OPTARG;;
		?) printf "Usage: stream [options (hadu)] [-u] [user]\n" && exit
        esac
done

shift $((OPTIND -1))

numberUsers=`who|wc -l`

trap CLEANUP SIGINT

function HELPMENU(){
        printf "\n"
	printf "                Stream Help	    	        \n"
        printf "        help            	-h		\n"
	printf "        accept			-a		\n"
	printf "        deny			-d		\n"
	printf "        user			-u [username]	\n"
        printf "\n"
	exit
}


function STREAM_ACCEPT(){
	# Check if fifo already exists
	ls /tmp/stream.out >/dev/null 2>&1
	[[ $? -gt 0 ]] && mkfifo /tmp/stream.out
	
	# Signals SIGUSR1 to other users stream.sh process
	sudo kill -10 `pgrep -u $otherUser stream`
	
	# Shoot the typescript into the fifo
	script -f /tmp/stream.out
	CLEANUP
}

function STREAM_DENY(){
	# Signals SIGUSR2 to otherUsers stream.sh process
	sudo kill -12 `pgrep -u $otherUser stream`
	otherUsersTTY=`who|grep -w $otherUser|awk '{print $2}'`
	printf "$USER has denied your request.\n"|write $otherUser $otherUsersTTY
	CLEANUP
}

function STREAM_SESSION(){
	# Read the typescript fifo if accepted
#	sleep 2
	cat /tmp/stream.out
}

function ASK(){
	# Write to other users TTY with a request to stream
	printf "\t$USER has requested to stream your TTY \n\
	Run: stream -a to allow or -d to deny\n"|write $otherUser $otherUsersTTY
	
	# Write invite info to temp file
	printf "$USER `ps ax|grep $$|grep -v grep|awk '{ print $2 }'`" > /tmp/invite

	# Set up signal traps to recieve SIGUSR1 and SIGUSR2
	trap CLEANUP SIGUSR2
	trap STREAM_SESSION SIGUSR1

	# Set up waiting area
	printf "Waiting for user to accept.\nPress, 'Ctrl + C' to quit.\n"	
	for x in {0..11}
	do
		sleep 5
	done && echo "Timed out waiting for a reply." && CLEANUP
}

function USERS_TTY_SELECT(){
	# Reads in TTY selection
	printf "\t$otherUser's TTYs\n"
	who|grep $otherUser
	printf "Please select a valid TTY or press Ctrl + C to quit.\n> "
	read otherUsersTTY

	# Check that supplied TTY exists
	if [[ `who|grep -w $otherUsersTTY|wc -l` = 0 ]]
	then
		printf "\n\tInvalid TTY!\n"
		USERS_TTY_SELECT	# Recurses if TTY does not exist
	fi

	# Checks if script is called in accept mode
	[[ $ACCEPT != 1 ]] && ASK
	STREAM_ACCEPT
}

function USER_SELECT(){
	# Reads in User selection
	printf "Users: "
	who|awk '{print $1}'|uniq|tr '\n' ' '
	printf "\nPlease select a valid user or press Ctrl + C to quit.\n> "
	read otherUser 

	# Check that suplied User exists
	grep -q $otherUser /etc/passwd
	if [[ $? -gt 0 ]]
	then
		printf "\n\tInvalid user!\n"
		USER_SELECT	# Recurses if User does not exist
	fi
	
	# Checks if script is called in accept mode and if so accepts 
	[[ $ACCEPT = 1 ]] && STREAM_ACCEPT

	# Checks if more than one TTY exists for user and if so calls USERS_TTY_SELECT
	[[ `who|grep -w $otherUser|wc -l` -gt 1 ]] && USERS_TTY_SELECT

	# Otherwise, sets users TTY
	otherUsersTTY=`who|grep -w $otherUser|awk '{print $2}'`
	
	ASK
} 

function CLEANUP(){
	rm /tmp/stream.out /tmp/invite >/dev/null 2>&1
	exit
}

# Prints help menu
[[ $HELP = 1 ]] && HELPMENU

#[[ $DENY = 1 ]] && STREAM_DENY #echo "Deny currently disabled"

if [[ $ACCEPT = 1 ]]
then
	[[ -f /tmp/invite ]] && otherUser=`awk '{print $1}' /tmp/invite` && STREAM_ACCEPT
	if [[ ! -f /tmp/invite ]]
	then 
		[[ ! -z $U ]] && otherUser=$U && STREAM_ACCEPT
	else	
		printf "\n\tNo invite found!!\nSelect the user who sent you the invite\n"
		USER_SELECT
	fi
elif [[ $DENY = 1 ]]
then
	[[ -f /tmp/invite ]] && otherUser=`awk '{print $1}' /tmp/invite` && STREAM_DENY
	[[ -f /tmp/invite ]] || printf "\n\tNo invite found!!\n\n"
#If User is specified with -u then set values and ask specified user
elif [[ ! -z $U ]] 
then
	# Check username validity
	grep -q $U /etc/passwd
	[[ $? -gt 0 ]] && printf "Invalid Username: $U\n" && USER_SELECT #exit

	otherUser=$U
	if [[ $numberUsers -eq 2 ]]
	then
		otherUsersTTY=`who|grep -w $otherUser|awk '{print $2}'`
		ASK
	else
		USERS_TTY_SELECT
	fi
# If only 2 users logged-in then set values and ask the other user
elif [[ $numberUsers -eq 2 ]]
then
	otherUser=`who|grep -v $USER|awk '{print $1}'`
	otherUsersTTY=`who|grep -v $USER|awk '{print $2}'`
	ASK

elif [[ $numberUsers -gt 2 ]] && [ -z "$U" ] 
then
	USER_SELECT
fi
