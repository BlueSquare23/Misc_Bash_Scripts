#!/usr/bin/env bash
# This script is meant to be a somewhat comprehensive IP address checker
# script. It returns information about an IP's reputation based on a number of
# sources (ipinfo.io, ip abuse db api, and ipdata.co threat api).
# Written by John R., 2022.

# Get your free API keys by visiting the links below.
# https://www.abuseipdb.com/register
# https://dashboard.ipdata.co/sign-up.html
IPDATA_API_KEY=""
IPDB_API_KEY=""

trap exit SIGINT

function Help(){
    cat <<"    EOF" | cut -c5-
    Usage:
    
            check-ip.sh [options]
    
    Options:
    
        -h                 Print this help menu
        -a IP_ADDRESS      IP address to check
        -r                 Output raw json 

    EOF
    exit
}

# Bash colors.
red="$(tput setaf 1)"
green="$(tput setaf 2)"
yellow="$(tput setaf 3)"
cyan="$(tput setaf 6)"
reset="$(tput sgr0)"

# Uses mini python script in a heredoc to validate IP address.
function ValidateIP() {
    python3 <(cat <<EOF
# Quickly validates an IP address. I'm not even going to try to write the regex
# for both ipv4 & ipv6. Python's already done that. Zero IO. Exits clean if
# valid ip, exits 7 if invalid.

import sys
import ipaddress

# Validate IP Addr.
def valid_ip(address):
	try: 
		print(ipaddress.ip_address(address))
		return True
	except:
		return False

if len(sys.argv) == 1:
	print("Usage: valid_ip.py IP_ADDRESS")
	exit(1)

# Mute try / except output.
old_stdout, old_stderr = sys.stdout, sys.stderr
sys.stdout = open('/dev/null', 'w')
sys.stderr = open('/dev/null', 'w')

if not valid_ip(sys.argv[1]):
	exit(7)
EOF
) "$1"
}

# Wraps IP Abuse DB API curl query.
function IPDB_Check() {
    curl -s \
        -H "Accept: application/json" \
        -H "Key: $IPDB_API_KEY" \
        "https://api.abuseipdb.com/api/v2/check?ipAddress=$IP_ADDR&maxAgeInDays=90"
}

# If there's only one arg and its an IP, assign it to the IP_ADDR var.
if [[ $# -eq 1 ]]; then
    if ValidateIP $1; then
        IP_ADDR=$1
    fi
fi

# Getopts handles optional arguments passed to the script.
while getopts :a:r options; do
    case ${options} in
        a) IP_ADDR=$OPTARG;;
        r) RAW=1;;
        ?) Help
    esac
done

# If no IP_ADDR optarg, take IP_ADDR via stdin.
if [[ -z $IP_ADDR ]]; then 
    # If running interactivly prompt for input.
    [[ -t 0 ]] &&
        echo -n "Enter an IP Address: "

    read IP_ADDR
fi

# Validate IP_ADDR.
if ! ValidateIP $IP_ADDR; then
    echo -e "${red}Invalid IP: $IP_ADDR${reset}"
    exit 7
fi

ip_info_json=$(curl -s ipinfo.io/$IP_ADDR)

## Is Good IP Checks.

# CF check.
ip_org=$(jq -r '.org' <<< $ip_info_json)
if grep -iq "Cloudflare" <<< "$ip_org"; then
    if [[ $RAW -eq 1 ]];then
        cf_json="{\"is_cloudflare\":\"yes\"}"
        json_results=$(jq -s add <<< "$json_results $cf_json")
    else
        echo -e "${green}Is Cloudflare IP!!! No further checks.${reset}"
        exit
    fi
fi

# If not called in raw json mode, output plaintext info.
if [[ -z $RAW ]]; then
    ip_hostname=$(jq -r '.hostname' <<< $ip_info_json)
    ip_city=$(jq -r '.city' <<< $ip_info_json)
    ip_region=$(jq -r '.region' <<< $ip_info_json)
    ip_country=$(jq -r '.country' <<< $ip_info_json)
    ip_org=$(jq -r '.org' <<< $ip_info_json)

    echo
    echo "##### IP Info"
    echo -e "${green}  IP       ${reset}:$yellow $IP_ADDR $reset"
    echo -e "${green}  Hostname ${reset}:${cyan} $ip_hostname $reset"
    echo -e "${green}  City     ${reset}: $ip_city"
    echo -e "${green}  Region   ${reset}: $ip_region"
    echo -e "${green}  Country  ${reset}: $ip_country"
    echo -e "${green}  Org      ${reset}: $ip_org"
else
    json_results=$(jq -s add <<< "$json_results $ip_info_json")
fi

## Is Bad IP Checks.

# IP abuse database check.
ipdb_json=$(IPDB_Check $IP_ADDR)
abuse_score=$(jq -r '.data.abuseConfidenceScore' <<< $ipdb_json)
if [[ $abuse_score -gt 0 ]]; then
    if [[ $RAW -eq 1 ]]; then
        json_results=$(jq -s add <<< "$json_results $ipdb_json")
    else
        ip_abuse_score=$(jq -r '.data.abuseConfidenceScore' <<< $ipdb_json)
        ip_isp=$(jq -r '.data.isp' <<< $ipdb_json)
        ip_last_reported=$(jq -r '.data.lastReportedAt' <<< $ipdb_json)
        ip_usage_type=$(jq -r '.data.usageType' <<< $ipdb_json)

        echo -e "${red}##### IP Found in AbuseIPDB${reset}"
        echo "  https://www.abuseipdb.com/check/$IP_ADDR"
        echo -e "${green}  Abuse Score   ${reset}:${red} $ip_abuse_score $reset"
        echo -e "${green}  ISP           ${reset}:${cyan} $ip_isp $reset"
        echo -e "${green}  Last Reported ${reset}: $ip_last_reported"
        echo -e "${green}  Usage Type    ${reset}:${cyan} $ip_usage_type $reset"
    fi
fi

# IPdata.co API checks.
# Checks: is_tor, is_datacenter, is_known_attacker, is_known_abuser,
# blocklists, and much more.

ipdataco_json=$(curl -s https://api.ipdata.co/${IP_ADDR}?api-key=${IPDATA_API_KEY})
threat_json=$(jq -r '.threat' <<< $ipdataco_json)
is_threat=$(jq -r '.is_threat' <<< $threat_json)

if [[ $is_threat == "true" ]]; then
    if [[ $RAW -eq 1 ]]; then
        json_results=$(jq -s add <<< "$json_results $threat_json")
    else
        echo -e "${red}##### IP Found in IPData Co's Threat DB${reset}"
        [[ $(jq -r '.is_threat' <<< $threat_json) == "true" ]] &&
            echo -e "${green}  ✓ ${red}IP is a threat! $reset"
        [[ $(jq -r '.is_tor' <<< $threat_json) == "true" ]] &&
            echo -e "${green}  ✓ ${red}IP is known tor exit node! $reset"
        [[ $(jq -r '.is_datacenter' <<< $threat_json) == "true" ]] &&
            echo -e "${green}  ✓ ${red}IP is datacenter! $reset"
        [[ $(jq -r '.is_proxy' <<< $threat_json) == "true" ]] &&
            echo -e "${green}  ✓ ${red}IP is proxy! $reset"
        [[ $(jq -r '.is_known_attacker' <<< $threat_json) == "true" ]] &&
            echo -e "${green}  ✓ ${red}IP is a known attacker! $reset"
        [[ $(jq -r '.is_known_abuser' <<< $threat_json) == "true" ]] &&
            echo -e "${green}  ✓ ${red}IP is a known abuser! $reset"
    fi
fi

if [[ -n $json_results ]]; then
    # Prettify json if in term.
    [[ -t 0 ]] &&
        jq -r <<< $json_results 2>/dev/null ||
        echo $json_results
fi
