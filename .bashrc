export PATH=$PATH:/home/bluesoldier/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin/:/usr/krb5/bin:/usr/pair/bin:/usr/local/bin 

shopt -s autocd #Automatically changes directory without having to type cd

# System-wide .bashrc file for interactive bash(1) shells.

# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
export PS1='${debian_chroot:+($debian_chroot)}\[\e[57m\]\u\[\e[m\]\[\e[93m\]@\[\e[m\]\[\e[57m\]\h\[\e[m\]\[\e[93m\]:\[\e[m\]\[\e[93m\]\\$\[\e[m\]\[\e[57m\]\W\[\e[m\]\[\e[93m\]>\[\e[m\] '
#\u@\h:\w\$ (<-- Default) [\e[m\]\[\e[57m\]\w\[\e[m\]\[\e[93m\]:\[\e[m\]\[\e[93m\]\\$\[\e[m\]

# Commented out, don't overwrite xterm -T "title" -n "icontitle" by default.
# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
#    ;;
#*)
#    ;;
#esac

# enable bash completion in interactive shells
#if ! shopt -oq posix; then
#  if [ -f /usr/share/bash-completion/bash_completion ]; then
#    . /usr/share/bash-completion/bash_completion
#  elif [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#  fi
#fi

# sudo hint
if [ ! -e "$HOME/.sudo_as_admin_successful" ] && [ ! -e "$HOME/.hushlogin" ] ; then
    case " $(groups) " in *\ admin\ *|*\ sudo\ *)
    if [ -x /usr/bin/sudo ]; then
	cat <<-EOF
	To run a command as administrator (user "root"), use "sudo <command>".
	See "man sudo_root" for details.
	
	EOF
    fi
    esac
fi

# if the command-not-found package is installed, use it
if [ -x /usr/lib/command-not-found -o -x /usr/share/command-not-found/command-not-found ]; then
	function command_not_found_handle {
	        # check because c-n-f could've been removed in the meantime
                if [ -x /usr/lib/command-not-found ]; then
		   /usr/lib/command-not-found -- "$1"
                   return $?
                elif [ -x /usr/share/command-not-found/command-not-found ]; then
		   /usr/share/command-not-found/command-not-found -- "$1"
                   return $?
		else
		   printf "%s: command not found\n" "$1" >&2
		   return 127
		fi
	}
fi

#Colors
export GREP_COLOR='3;93'

#Aliases

#alias ksu='/usr/bin/ksu -n bluesoldier23/root -e /bin/bash --rcfile ~bluesoldier23/.bashrc'
alias sudo='sudo '
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
#alias kinit="/usr/bin/kinit -f bluesoldier23;"
#alias go="/usr/pair/bin/go.pl;"
alias ll="ls -lah"
#alias tikcl="/usr/local/bin/tikcl"
alias killchrome="kill $(ps auxwww |grep chrome | head -1 |awk '{print $2}') "


#Functions

function hosts(){
host -t a $1
host -t mx $1
host -t ns $1 
host -t txt $1
}

function cdr(){
#This function serves as a recusive cd
#If there is only one dir below the pwd then cd again
let count=0

for x in $(ls $1);
do
let count++
done

if [ $count -gt 1 ]
then
   echo "There are multiple directories below $1"
   dirs=$(ls $1)
   echo $dirs
elif [ $count -eq 1 ]
then
   subdir=$(ls $1)
   cd $1 && cd $subdir
fi
}

mkcdir(){
mkdir $1
cd $1
}

#SSH aliases
alias LaptopServer='ssh -p2222 bluesoldier23@192.168.1.214'
alias WebServer='ssh johnlradford@johnlradford.pairserver.com'
alias RaspberryPi='ssh pi@192.168.1.181'
alias lld='ll | egrep "d--|dr-|d-w|drw"'
