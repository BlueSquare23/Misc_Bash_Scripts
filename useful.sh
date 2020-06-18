#!/bin/bash
#This is a very useful program
export PATH=$PATH:/usr/games

declare -a cowsayz
i=0

for x in `cowsay -l|grep -v file`
do 
	cowsayz[$i]=$x
	((i++))
done

rand=$((1 + $RANDOM % (($i - 1))))
i=0

for x in "${cowsayz[@]}"
do 
	if [ $i -eq $rand ]
	then
		fortune -s|cowsay -f "${cowsayz[$i]}"
	fi
	((i++))
done
