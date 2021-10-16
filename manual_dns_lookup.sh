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

	zone_depth=$(grep -o "\." <<< "$domain"|wc -l)	
	echo "$zone_depth"
}

############ recursiveNsLookup()
# The recursiveNsLookup() finds the authoritative name servers for a supplied
# domain. It does this by running successive manual name server lookups from the
# root resolver server on down. I'm using a dig command here to keep asking for
# the next NS server in the chain.

function recursiveNsLookup(){
	ns_serv=$1

	# If the zone_depth value is zero return the ns server
	[[ $zone_depth = 0 ]] && echo "$ns_serv" && return

	# Uses dig to find an authoritative name server for this level in the
	# zone hierarchy.
	ns_serv=$(dig @"$ns_serv" any "$domain" \
		| grep -A1 "AUTHORITY SECTION" \
		| tail -1 \
		| awk '{print $5}')

	# Decrement the zone_depth value after ns lookup. 
	((zone_depth--))

	# Recurse with this level's ns_serv
	recursiveNsLookup "$ns_serv"
}

############ main()
# The main() function gets the domain from user input, finds out how many
# subdomains aka DNS zones deep the supplied domain is, then recurses using
# that zone depth value as a base case to find an authoritative name server for
# the domain, and finally runs a dig against that name server to get the
# domains address record (aka its A record).

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

	# Runs a dig for the A record for domain.
	dig @"$auth_ns_serv" A "$domain"|grep -A1 "ANSWER SECTION"
}

main
