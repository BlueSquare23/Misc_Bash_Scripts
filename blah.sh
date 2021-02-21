#!/usr/bin/env bash
# This is a test bash/expect script for sending Email via an openssl wrapped
# telnet session. This script is just a proof of concept and is tailored to a
# specific Postfix configuration. Your mileage may vary.  
# Written by John R., February 2021

echo -n "Email Address: "
read EMAIL_ADDR

echo -n "Password: "
read -s PASS

DOMAIN=`echo $EMAIL_ADDR|cut -d @ -f2`

MAILSERVER=`host -t mx $DOMAIN|awk '{print $7}'|sed 's/\.$//'`

AUTH_STR=`echo -ne "$EMAIL_ADDR\x00$EMAIL_ADDR\x00$PASS"|base64 --wrap=0`

echo $AUTH_STR

/usr/bin/expect -f <(cat << EOF

set timeout -1

spawn openssl s_client -connect $MAILSERVER:587 -starttls smtp -no_ssl3

expect "250 CHUNKING\r"
 
send -- "helo $DOMAIN\r"

expect "250 $MAILSERVER\r"

send -- "AUTH PLAIN\r" 

expect "334"

send -- "$AUTH_STR\r"

expect "235 2.7.0 Authentication successful\r"

send -- "mail from: $EMAIL_ADDR\r"

expect "250 2.1.0 Ok\r"

send -- "rcpt to: $EMAIL_ADDR\r"

expect "250 2.1.5 Ok\r"

send -- "data\nSubject: Test Email\nHello,\n\nThis is a test Email!\n.\r"

expect "250 2.0.0 Ok: queued as"

send -- "quit\r"

expect eof

EOF
)

