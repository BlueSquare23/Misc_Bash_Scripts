#!/usr/bin/env bash
# This script updates WordPress installations automatically. Requires the
# WordPress command line tool, `wp-cli` in order to work.
# Written by John R., April 2021

updateWP(){
	WP_DIR=$1
	wp-cli --path=$WP_DIR core update 2> /dev/null
	wp-cli --path=$WP_DIR plugin update --all 2> /dev/null
	wp-cli --path=$WP_DIR theme update --all 2> /dev/null
}

updateWP "/path/to/wordpress/site1/"
updateWP "/path/to/wordpress/site2/"
updateWP "/path/to/wordpress/site3/"
