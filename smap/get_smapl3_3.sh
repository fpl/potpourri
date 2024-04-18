#!/bin/sh

for year in 2024
do
	for month in 01 02
	do
		limit=10
		for day in $(seq -w 01 $limit)
		do
			wget --load-cookies ~/.urs_cookies --save-cookies ~/.urs_cookies --keep-session-cookies --no-check-certificate \
				--auth-no-challenge=on -r --reject "index.html*" -np -e robots=off -A *.h5 \
				https://n5eil01u.ecs.nsidc.org/SMAP/SPL3SMP_E.006/$year.$month.$day/
		done
	done
done
