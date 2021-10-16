#!/usr/bin/env bash
# This script is a manual DNS lookup demonstration. It works by querying the
# DNS network from the root resolver servers on down. Obviously, there are
# tools like `host` and `nslookup` that do this better. This is a proof of
# concept / educational script.
# Written by John R., Oct. 2021

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
	# If the second to last character is a . then exit because that means
	# the domain name is malformed. More checking of user input to come.
	[[ "${domain: -2:-1}" = '.' ]] && exit

	# If the last character is . then pass otherwise append a . in prep for
	# zone_depth expression.
	[[ "${domain: -1}" = '.' ]] || 
			domain="${domain}."

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

	# If new_ns_serv empty return old ns serv
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
