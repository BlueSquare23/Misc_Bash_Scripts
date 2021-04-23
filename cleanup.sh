#!/usr/bin/env bash
# This script helps me clean up old files and directories by allowing me to
# loop through all files in the working dir and stage unneeded files/dirs for deletion.

trap exit SIGINT

function getFileType(){
	[[ -z $1 ]] && exit 2
	[[ -d $1 ]] && echo directory && return
	[[ -e $1 ]] && echo file && return
	echo "FileType isn't known!"
}

function preview(){
	echo "Preview for $1:"
	echo
	[[ $fileType = "file" ]] && head $1
	[[ $fileType = "directory" ]] && ls $1
	echo
	ask $1
}

function ask(){
	fileType=`getFileType $1`

	echo "Do you want to delete this $fileType, $1?"
	echo "Yes: y/Y"
	echo "No: n/N"
	echo "Preview: p/P"
	echo -n "> "

	read reply
	echo
	case $reply in
		y|Y) deleteItems=(${deleteItems[@]} $1) && echo "$1 Marked for deletion."
		;;
		p|P) preview $1
		;;
		n|N) echo "Skipping $1."
		;;
		*) echo "!!!Input Error!!! Please try again." && ask $1
		;;
	esac
	echo

}

function deleteAsk(){
	echo
	echo "The following have been marked for deletion:"
	echo
	echo ${deleteItems[@]}
	echo
	echo -n "Would you like to perminantly delete them? (y/n): "
	read reply

	case $reply in
		y|Y) rm -R "${deleteItems[@]}" && echo "Items deleted!"
		;;
		n|N) echo "Exiting, no files deleted" && exit
		;;
		*) printf "\n!!!Input Error!!! Please try again.\n" && deleteAsk
		;;
	esac

}

declare -a deleteItems=()
OIFS="$IFS"
IFS=$'\n'
for fileObj in `ls -1`
do
	ask $fileObj
done 

deleteAsk
