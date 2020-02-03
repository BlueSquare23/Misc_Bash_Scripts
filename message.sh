#!/bin/bash
#This scipt is based off of `wall` and `write` and allows the user to
#broadcast a message to the wall or to write it to their TTY.
#See `man write` and `man wall` for more infomation.

WRITE=/usr/bin/write
WALL=/usr/bin/wall
DATE=/bin/date
STAT=/usr/bin/stat
SUDO=/usr/bin/sudo
CAT=/bin/cat
WHO=/usr/bin/who
AWK=/usr/bin/awk
HEAD=/usr/bin/head

#Get options which have been passed
while getopts :hwe: options 
do
        case ${options} in
                h) HELP=1;;
		w) WRITE=1;;
                e) EDITOR=$OPTARG;;
		?) printf "Usage: message [-h] [-e] [args]\n"
        esac
done
shift $((OPTIND -1))

function HELPMENU(){
        printf "\n"
	printf "                Message Help            \n"
        printf "        help            -h		\n"
	printf "        write		-w		\n"
	printf "        editor          -e [editor]	\n"
        printf "\n"
	exit
}

if [[ $HELP = 1 ]]
then
	HELPMENU
fi

printf "Write then save your message.\n" > /tmp/`whoami`.message

#Define opening mtime epoc
OEpoc=$($STAT --format %Z /tmp/`whoami`.message)

if [[ $EDITOR != '' ]]
then
	$EDITOR /tmp/`whoami`.message
fi

#Define closing mtime epoc
CEpoc=$($STAT --format %Z /tmp/`whoami`.message)

#Either writes to the wall or to another users tty
if [[ $WRITE = 1 ]] && [[ $OEpoc -lt $CEpoc ]]
then
	$WHO
	printf "Select user to message: \n"
	read USER
	TTY=$($WHO|grep $USER|$AWK '{print $2}'|$HEAD -1)
	printf "* User, `whoami` wrote on `date '+%D at %T'` to $USER:\n" >> /var/log/chat.log
	$CAT /tmp/`whoami`.message >> /var/log/chat.log 
	$CAT /tmp/`whoami`.message | write $USER $TTY
	printf "" > /tmp/`whoami`.message

#If the files was changed, (i.e. if the mtime changed) wall the file
elif [[ $OEpoc -lt $CEpoc ]]
then
	printf "* User, `whoami` wrote on `date '+%D at %T'`:\n" >> /var/log/chat.log
	$CAT /tmp/`whoami`.message >> /var/log/chat.log 
	$SUDO $WALL /tmp/`whoami`.message
	printf "" > /tmp/`whoami`.message
fi
