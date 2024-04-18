#!/bin/sh
#
# This script download previous years of SMAP L3 v5.
# Note that at the date of this script v6 was not available before begin of
# Dec 2023.
#

for year in 2021 2022 2023
do
	for month in $(seq -w 1 12) 
	do
		case $month in
			01|03|05|07|08|10|12)
				limit=31
				;;
			04|06|09|11)
				limit=30
				;;
			02)
				limit=28
				;;
		esac
		for day in $(seq -w 01 $limit)
		do
			if [ "$year" = '2023' -a "$month" = '12' -a "$day" = '03' ]
			then
				exit
			fi
			wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --keep-session-cookies --no-check-certificate \
				--auth-no-challenge=on -r --reject "index.html*" -np -e robots=off -A *.h5 \
				https://n5eil01u.ecs.nsidc.org/SMAP/SPL3SMP_E.005/$year.$month.$day/
		done
	done
done
