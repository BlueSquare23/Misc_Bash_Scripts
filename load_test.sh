#!/bin/bash
# This script creates an artificial load
# By, John Radford July 2020 
# github https://bluesquare23.sh
# Usage: load_test.sh [number of cores]

killall dd >/dev/null 2>&1

ncores=`lscpu|\
	grep "CPU(s):"|\
	grep -v NUMA|\
	awk '{print $2}'`

full_load(){
	i=1
	while [[ $i -le $ncores ]]
	do
		dd if=/dev/zero of=/dev/null &
		((i++))
	done
}

partial_load(){
	i=1

	! [[ "$1" =~ ^[0-9]+$ ]] && \
	        >&2 echo "Integers only!" && \
		return 1
		
	[[ $1 -gt $ncores ]] && \
		>&2 echo "Value larger than core count!" && \
		return 1

	while [[ $i -le $1 ]]
        do
                dd if=/dev/zero of=/dev/null &
                ((i++))
        done	
}

 [ -z $1 ] && \
	 full_load || \
	 partial_load $1 && \
	 echo "Run, \`killall dd\` to stop the stress test."
