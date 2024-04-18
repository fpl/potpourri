#!/bin/sh
#
# This script downloads SMAP L3 products v6 for current year and until current month
# and day, skipping existing products.
#

for year in $(date +%Y)
do
	for month in $(seq -w 04 `date +%-m`)
	do
		if [ "$month" = "$(date +%m)" ]
		then
			limit=$(expr `date +%-d` - 2)
		else
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
		fi
		for day in $(seq -w 01 $limit)
		do
			wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --keep-session-cookies --no-check-certificate \
				--auth-no-challenge=on -r --reject "index.html*" -np -nc -e robots=off -A *.h5 \
				https://n5eil01u.ecs.nsidc.org/SMAP/SPL3SMP_E.006/$year.$month.$day/
		done
	done
done
