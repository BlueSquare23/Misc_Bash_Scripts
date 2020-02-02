# My .bashrc file for interactive bash(1) shells.

# To enable the settings / commands in this file for login shells as well,
# this file has to be sourced in /etc/profile.

#PATH
export PATH=$PATH:/usr/sbin:/usr/bin:/sbin:/bin:/root/bin/:/home/bluesoldier23/bin:/usr/local/sbin:/usr/local/bin

#Automatically changes directory to path w/out cd
shopt -s autocd 

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
#export PS1='${debian_chroot:+($debian_chroot)}\[\e[57m\]\u\[\e[m\]\[\e[93m\]@\[\e[m\]\[\e[57m\]\h\[\e[m\]\[\e[93m\]:\[\e[m\]\[\e[93m\]\\$\[\e[m\]\[\e[57m\]\W\[\e[m\]\[\e[93m\]>\[\e[m\]'
export PS2="> "

#Setting the right prompt
rightprompt()
{
    printf "%*s" $COLUMNS "`date '+%D %r'`"
}

PS1='\[$(tput sc; rightprompt; tput rc)\]${debian_chroot:+($debian_chroot)}\[\e[57m\]\u\[\e[m\]\[\e[93m\]@\[\e[m\]\[\e[57m\]\h\[\e[m\]\[\e[93m\]:\[\e[m\]\[\e[93m\]\\$\[\e[m\]\[\e[57m\]\W\[\e[m\]\[\e[93m\]>\[\e[m\] '


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

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ll="ls -lh"
alias la="ls -lah"

#Functions

function hosts(){
host -t a $1
host -t mx $1
host -t ns $1 
host -t txt $1
}

function phpinfo(){
echo "<? passthru('whoami'); phpinfo(); ?>" >> z.php
user=$(ls -lah |head -2|tail -1|awk '{print $3}')
group=$(ls -lah |head -2|tail -1|awk '{print $4}')
chown $user:$group z.php
}

function whose(){
whois $1|sed -n '/Domain Name/,/Last update/p'
}

function mkcdir(){
mkdir $1
cd $1
}

#Checks if build is still running
function bcheck(){
BUILD=false
while [ $BUILD = false ]
do
        ps aux|grep build|grep -v grep
        if [[ `echo $?` = 0 ]]
        then
                echo "Build still running..."
                sleep 5
        else
                echo "Build finished running!"
                BUILD=true
        fi
done
}
