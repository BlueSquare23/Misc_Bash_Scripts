#!/usr/bin/env bash
# This script is meant to run on a cronjob every minute. It simply pings a
# remote host to check if it is up. If there are more than five failed pings in
# a row the script sends and Email. Must be reset manually after sending Email.

FAILS=0
EMAIL_ADDRESS="YOUR_EMAIL"
SERVER="SERVER_IP/HOSTNAME"
EMAILTXT="/path/to/email.txt"
SLEEP=5
INDEX=0

while [[ $INDEX -lt 5 ]]; do
    ping -c 1 $SERVER >/dev/null 2>&1
    if [ $? -ne 0 ] ; then #if ping exits nonzero...
        FAILS=$[FAILS + 1]
    else
        FAILS=0
    fi
    if [ $FAILS -gt 4 ] && [ ! -f $EMAILTXT ]; then
        FAILS=0
        printf "From: SENTERS_ADDRESS \nDate: `date`\nTo: $EMAIL_ADDRESS\nSubject: $SERVER Outtage\nHello,\n\n$SERVER is not responding to pings. Is $SERVER down?\n" > $EMAILTXT
	mail -s "$SERVER Outtage" "$EMAIL_ADDRESS" < $EMAILTXT
    fi
    ((INDEX++))
    sleep $SLEEP #check again in SLEEP seconds
done
