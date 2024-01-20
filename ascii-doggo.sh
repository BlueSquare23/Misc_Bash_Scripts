#!/usr/bin/env bash
# Uses ascii-image-convert and the random.dog api to make ascii doggos.

doggo_url=$(curl -sm 2 "https://random.dog/woof.json?include=jpg" | jq -r '.url')
curl -s $doggo_url | ascii-image-converter -C -
echo "Doggo URL: $doggo_url"
