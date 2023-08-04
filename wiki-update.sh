#!/usr/bin/env bash
# This script is used to upgrade mediawiki installation(s) to the newest
# version.
# Written By, John R. 2022 https://johnlradford.io/

most_recent_relase_download_url=$(
	curl -s https://www.mediawiki.org/wiki/Download|\
	grep "Download .tar.gz instead"|\
	awk -F "href=" '{print $2}'|\
	awk '{print $1}'|\
	cut -d\" -f2
)

most_recent_tarball=$(cut -d/ -f6 <<< $most_recent_relase_download_url)
most_recent_folder=$(sed 's/.tar.gz//' <<< $most_recent_tarball)
most_recent_version_num=$(cut -d- -f2 <<< $most_recent_folder|cut -d. -f-2)

cd $HOME/public_html
wget $most_recent_relase_download_url
tar -xzvf $most_recent_tarball


updateWiki(){
	site=$1
    site_cur_version=$(grep MW_VERSION $site/includes/Defines.php | cut -d\' -f4 | cut -d. -f-2)

    if (( ! $(bc -l <<< "$most_recent_version_num>$site_cur_version") )); then
        echo "$(basename $site) Already Up-To-Date. Version: $site_cur_version"
        return
    fi

	set -x
	mv $site $site.bak
	cp -r $most_recent_folder $site
	cp $site.bak/LocalSettings.php $site
	cp -r $site.bak/images $site
	cp $site.bak/.htaccess $site
	cp $site.bak/.passwd $site
	cp $site.bak/favicon.ico $site
	php $site/maintenance/update.php
}

updateWiki $HOME/public_html/wiki.example.com

rm -rf $most_recent_tarball $most_recent_folder
