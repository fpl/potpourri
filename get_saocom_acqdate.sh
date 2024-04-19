#!/bin/sh
#
# Extract SAOCOM acquisition dates from metadata XML file (xemt files)
#

if [ $# -ne 1 ]
then
    echo "usage: $0 <directory>"
    exit 255
fi

find "$1" -name '*.xemt' -exec awk 'BEGIN {FS=""; at=0} /<acquisitionTime>/ {at=1} /<\/acquisitionTime>/ {at=0} /startTime/ {if (at!=0) {gsub(/ /,"",$0); print FILENAME, substr($0,12,10)}}' {} \;

