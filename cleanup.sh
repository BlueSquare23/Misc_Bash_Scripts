#!/usr/bin/env bash
# This script helps me clean up old files and directories by allowing me to
# loop through all files in the working dir and stage unneeded files/dirs for
# deletion. Written by John R., Aug. 2020

trap exit SIGINT

function getFileType(){
	[[ -z $1 ]] && exit 2
	[[ -d $1 ]] && echo directory && return
	if [[ -e $1 ]]; then
        if [[ "$(file "$1")" =~ 'ASCII text' ]]; then
            echo text_file
        else
            echo other_file
        fi
        return
    fi
	echo "FileType isn't known!"
}

function preview(){
	echo "Preview for $1:"
	echo
	if [[ $file_type = "text_file" ]]; then 
        if [[ $(wc -l "$1") -gt $(tput lines) ]]; then
           cat "$1"
        else
           less "$1"
        fi
    fi
	[[ $file_type = "other_file" ]] && open "$1"
	[[ $file_type = "directory" ]] && ls "$1"
	echo
	ask "$1"
}

function ask(){
	file_type=$(getFileType "$1")

	echo "Do you want to delete this $file_type, $1?"
	echo "Yes: y/Y"
	echo "No: n/N"
	echo "Preview: p/P"
	echo -n "> "

	read -r reply
	echo
	case $reply in
		y|Y) deleteItems=("${deleteItems[@]}" "$1") && echo "$1 Marked for deletion."
		;;
		p|P) preview "$1"
		;;
		n|N) echo "Skipping $1."
		;;
		*) echo "!!!Input Error!!! Please try again." && ask "$1"
		;;
	esac
	echo

}

function deleteAsk(){
	echo
	echo "The following have been marked for deletion:"
	echo
	echo "${deleteItems[@]}"
	echo
	echo -n "Would you like to permanently delete them? (y/n): "
	read -r reply

	case $reply in
		y|Y) rm -rf "${deleteItems[@]}" && echo "Items deleted!"
		;;
		n|N) echo "Exiting, no files deleted" && exit
		;;
		*) printf "\n!!!Input Error!!! Please try again.\n" && deleteAsk
		;;
	esac

}

declare -a deleteItems=()

for fileObj in *; do
	ask "$fileObj"
done 

deleteAsk
