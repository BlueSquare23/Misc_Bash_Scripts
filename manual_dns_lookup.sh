#!/usr/bin/env bash
# This script is a manual DNS lookup demonstration. It works by querying the
# DNS network from the root resolver servers on down. Obviously, there are
# tools like `host` and `nslookup` that do this better. This is a proof of
# concept / educational script.
# Written by John R., Oct. 2021

############ domainCheckAndPrep()
# The domainCheckAndPrep() function does a few things. First it checks that the
# supplied domain name matches a standard domain name regex. Then it checks if
# the domain already has a trailing . character and appends it if it doesn't
# already have one. Then finally it check's that the domain is terminated by a
# valid TLD.

function domainCheckAndPrep(){
	# Validates supplied domain. Thanks ilkkachu for the validation regex!
	# https://unix.stackexchange.com/questions/548543/check-valid-subdomain-with-regex-in-bash
	valid_dom_regex='^([a-zA-Z0-9](([a-zA-Z0-9-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}\.?'
	! [[ $domain =~ $valid_dom_regex ]] && 
		echo "Not a valid domain!" &&
		exit 1

	# If the last character is . then pass otherwise append a . in prep for
	# zoneDepth().
	[[ "${domain: -1}" = '.' ]] || 
			domain="${domain}."

	# Accepted List of Top Level Domains (TLDs)
	TLDs=( 'com' 'net' 'org' 'info' 'io' 'ac' 'sh' 'me' 'us' 'ws' 'uk' \ 
		'biz' 'mobi' 'tv' 'cc' 'eu' 'ru' 'in' 'it' 'au' )

	domainsTLD=$(echo $domain|rev|cut -d . -f 2|rev)

	# Loops over TLDs and checks if domainsTLD string matches one of the tld
	# strings. If it does then pass, otherwise increment i.
	i=0
	for tld in ${TLDs[@]}; do
		if [[ $domainsTLD = $tld ]]; then
			:
		else
			((i++))
		fi
	done

	# If the value of i equals the number of elements in the TLDs array then
	# the domain name must not match any of the tlds and can therefore be
	# rejected.
	[[ $i -eq ${#TLDs[@]} ]] && 
		echo "Not a valid domain!" &&
		exit 1
}

############ zoneDepth()
# The zoneDepth() function returns the number of DNS zones deep a particular
# name is. For example, the domain bluesquare23.sh. is two DNS zones deep
# because there are two subdomains under the root domain .
#
#	  Zone 2	 Zone 1
#		\	/
#	  bluesquare23.sh.
#			  \
#			   Zone 0 - root domain 
#
# This value can be used to determine how many times you have to ask a
# different DNS name server for information before you get to an authoritative
# name server for the given domain.

function zoneDepth(){
	# Counts the number of periods in the $domain string.
	zone_depth=$(grep -o "\." <<< "$domain"|wc -l)	
	echo "$zone_depth"
}

############ recursiveNsLookup()
# The recursiveNsLookup() finds the authoritative name servers for a supplied
# domain. It does this by running successive manual name server lookups from
# the root resolver server on down. I'm using a dig command here to keep asking
# for the next NS server in the chain. This function returns / hits its base
# case when it can either find no more authorities for a given domain or it has
# dug to the correct depth in the zone hierarchy.

function recursiveNsLookup(){
	ns_serv=$1

	# If the zone_depth value is zero return the ns server
	[[ $zone_depth = 0 ]] && 
		echo "$ns_serv" && 
		return

	# Uses dig to find an authoritative name server for this level in the
	# zone hierarchy.
	new_ns_serv=$(dig @"$ns_serv" "$domain" \
		| grep -A1 "AUTHORITY SECTION" \
		| tail -1 \
		| awk '{print $5}')

	# If new_ns_serv empty return old ns_serv.
	[[ -z $new_ns_serv ]] && 
		echo $ns_serv && 
		return

	# Decrement the zone_depth value after ns lookup. 
	((zone_depth--))

	# Recurse with this level's ns_serv
	recursiveNsLookup "$new_ns_serv"
}

############ main()
# The main() function does a number of things; it gets the domain from user
# input, then it calls the zoneDepth() function to determine the zone_depth of
# the supplied domain, then it calls the recursiveNsLookup() function to get
# the auth_ns_serv for the supplied domain, finally it runs an A record lookup
# on auth_ns_serv to see if the supplied domain has an Address record. If the
# domain doesn't have an A record just return the auth_ns_serv name instead.

function main(){
	# Get's domain name from user.
	read -r -p "Please enter a domain name: " domain

	# Validate the supplied user input.
	domainCheckAndPrep

	# Find's number of DNS zones in domain name (aka number of subdomains)
	# via the zoneDepth() function.
	zone_depth=$(zoneDepth)

	# Get's the authoritative name servers for the domain via the
	# recursiveNsLookup() function. Uses first root resolver server,
	# a.root-servers.net.
	auth_ns_serv=$(recursiveNsLookup a.root-servers.net)

	# If there's an answer for A record print it else print auth name serv.
	response=$(dig @"$auth_ns_serv" A "$domain"|grep -A1 "ANSWER SECTION")
	[[ $? -eq 0 ]] &&
		echo "$response" ||
		echo "Authoritative Name Server for $domain is $auth_ns_serv" &&
		return
}

main
