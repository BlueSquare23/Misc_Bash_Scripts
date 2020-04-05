#!/bin/bash
#This scipt is based off of `wall` and `write` and allows the user to
#broadcast a message to the wall or to write it to their TTY.
#See `man write` and `man wall` for more infomation.

#Get options which have been passed
while getopts :hwrse: options 
do
        case ${options} in
                h) HELP=1;;
		w) WRITE=1;;
		r) READ=1;;
		s) SIL=1;;
                e) ED=$OPTARG;;
		?) printf "Usage: message [-h] [-e] [args]\n" && exit
        esac
done
shift $((OPTIND -1))

function HELPMENU(){
        printf "\n"
	printf "                Message Help    	        \n"
        printf "        help            	-h		\n"
	printf "        write to user		-w		\n"
	printf "        read chat		-r		\n"
	printf "        silent (no log)		-s		\n"
	printf "        editor          	-e [editor]	\n"
        printf "\n"
	exit
}

#Prints help menu
[[ $HELP = 1 ]] && HELPMENU

#Read from the chatlog
[[ $READ = 1 ]] && less +F /var/log/chat.log && exit

printf "Write then save your message.\n" > /tmp/`whoami`.message

#Define opening mtime epoc
OEpoc=$(stat --format %Z /tmp/`whoami`.message)

#Sets default editor to nano if not already set
[ -z "$ED" ] && [ -z "$EDITOR" ] && EDITOR=`which nano` 
[ -n "$ED" ] && EDITOR=$ED

$EDITOR /tmp/`whoami`.message

#Define closing mtime epoc
CEpoc=$(stat --format %Z /tmp/`whoami`.message)

#Either writes to the wall or to another users tty
if [[ $WRITE = 1 ]] && [[ $OEpoc -lt $CEpoc ]]
then
	w
	printf "Select user to message: \n"
	read user
	if [[ $SIL != 1 ]]
	then
		tty=$(who|grep $user|awk '{print $2}'|head -1)
		printf "* User, `whoami` wrote on `date '+%D at %T'` to $user:\n" >> /var/log/chat.log
		cat /tmp/`whoami`.message >> /var/log/chat.log 
	fi
	cat /tmp/`whoami`.message | write $user $tty
	printf "" > /tmp/`whoami`.message

#If the files was changed, (i.e. if the mtime changed) wall the file
elif [[ $OEpoc -lt $CEpoc ]]
then
	if [[ $SIL != 1 ]]
	then
		printf "* User, `whoami` wrote on `date '+%D at %T'`:\n" >> /var/log/chat.log
		cat /tmp/`whoami`.message >> /var/log/chat.log 
	fi
	sudo wall /tmp/`whoami`.message
	printf "" > /tmp/`whoami`.message
fi
