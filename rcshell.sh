#!/usr/bin/env bash
# A simple repl shell for Engineer Man's Piston API.

function cleanup(){
	[[ -f /tmp/data.json ]] && rm /tmp/data.json
	printf "\n"
	exit
}

trap cleanup SIGINT

piston_api_url="https://emkc.org/api/v1/piston/execute"

# Repl = tight while loop.
function main(){
    while true; do
    	echo -n "piston-shell> "
    	read -r cmd
        case $cmd in
          exit|quit|q)
            cleanup;;
        esac
    
        # Escape double quotes.
        cmd=$(sed 's/"/\\"/g' <<< $cmd)

    	echo "{\"language\":\"bash\", \"source\":\"$cmd\"}" > /tmp/data.json
    
    	curl --silent \
            -H "Content-Type: application/json" \
            -d "@/tmp/data.json" \
            -X POST $piston_api_url | jq -r '.output'
    done
}

[[ $1 == "main" ]] && main

# Run it through rlwrap for gnu readline support.
rlwrap ./$0 main
