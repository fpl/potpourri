#!/bin/sh
#
# This script download previous years of SMAP L4 v7.
#

for year in 2022 2023
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
		for day in $(seq -w 1 $limit)
		do
			wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --keep-session-cookies --no-check-certificate \
				--auth-no-challenge=on -r --reject "index.html*" -np -nc -e robots=off -A *.h5 \
				https://n5eil01u.ecs.nsidc.org/SMAP/SPL4SMGP.007/$year.$month.$day/
		done
	done
done
