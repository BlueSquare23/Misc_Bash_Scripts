#!/bin/bash
#This script creates directories within directories by calling the below function recursively. Here is how it works,

#First it create 3 directories named 1 2 3
mkdir {0..3}
function mndir(){
	#Then the main loop iterates over those three directories
	for x in {0..3}		
	do
		#Then it does two tests,
		#The first test checks if dir $x is empty
		#The second test is the base-case for the recursive call
		#It checks to make sure the function is only recursing to the specified depth --------------------------v
		if [[ $(ls $x|wc -l) -eq 0 ]] && [[ $( expr $(egrep -o '0|1|2|3|4|5|6|7|8|9' <<< `pwd`|wc -l) - 2 ) -lt 3 ]]
		then	#I had to do an expr subtraction on this ^ because my username has two number in it ----^ which otherwise would be counted in this egrep <<< pwd count
			#If the dir $x is both empty and not too deep then the program moves into dir $x and makes 3 sub directories
			cd $x
			mkdir {0..3}
			#Then the function calls itself and start the loop over filling in the empty directories to the specified depth
			mndir 
			#Last but not least after filling in the sub directories it pops up out of the recursion and cd's back up
			cd ..
		fi
	done
}
mndir
tree

#With the current settings, this script will create 340 directories. That is, 4^4 + 4^3 + 4^2 + 4.
#Because of the exponential nature of this script it is not recommended to run this with any more than a depth of 5.
#At a depth of 5, making 6 dirs (i.e. {0..5}) in each sub dir, you will create 55986 directories or 6^6 + 6^5 + 6^4 + 6^3 + 6^2 + 6.
#At 4kb per dir you'd be using ~220MB of diskspace on empty directories. Plus its a bash script so it'd just take forever to run.

#Pro tip: Clean up the mess this script makes easily by running rm -R [0-9] from the directory the script is in.
