#!/bin/bash
#This script reformats the output of various shell commands to aid in the hands on
#detection of nefarious actors via their IP addresses.
#Written by John Radford on August 4th, 2019
#Github: https://github.com/BlueSquare23

#Curl the ipinfo for the top IP addresses into a tmp file
echo "Curling..."

for x in $(awk '{print $2}' /usr/pair/apache/logs/apache_log |sort|uniq -c|sort|tail -10|awk '{print $2}')
do
   curl -s ipinfo.io/$x >> ips.tmp
done

#Putting the occurence each IP into an array for later printing
occ=()

declare -a occ

index=0

for i in $(awk '{print $2}' /usr/pair/apache/logs/apache_log |sort|uniq -c|sort|tail -10|awk '{print $1}')
do
   occ[$index]=$i
   ((index++))
done

#echo ${occ[@]}

#Putting the ip addresses into an array for later printing
ips=()

declare -a ips

index=0

for i in $(grep '"ip"' ips.tmp|awk '{print $2}'|cut -d '"' -f2)
do
   ips[$index]=$i
   ((index++))
done

#echo ${ips[@]}

#Space for output clarity
echo ""

#Running a for loop over the countries and discriminating accordingly
index=0

for country in $(grep country ips.tmp|awk '{print $2}'|cut -d '"' -f2)
do
   if [ $country != "US" ] #|| [ $country == "DE" ]
   then
      printf "Country: $country \nIP: ${ips[index]}\nOccurrences: ${occ[index]}\n\n"
      ((index++))
   fi
done

#Clean up
rm ips.tmp
