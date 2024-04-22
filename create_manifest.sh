#!/bin/sh
#
#    Copyright (C) 2010-2011 Francesco P. Lovergine <frankie@debian.org>
#    
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 2, 
#    as published by the Free Software Foundation.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#
#    On a Debian GNU system you should have a copy of the GPL license
#    as /usr/share/common-licenses/GPL
#

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 directory"
    exit 1
fi

if [ -z $(which dos2unix) ]; then
    echo "This script needs dos2unix installed"
    exit 3
fi
if [ -z $(which md5sum) ]; then
    echo "This script needs md5sum installed"
    exit 4
fi

DIR="$1"
if [ ! -d "$DIR" ]; then
    echo "$DIR is not a directory"
    exit 2
fi

MYTMPDIR=$(mktemp -d)

find "$DIR" -type f -exec readlink -f {} \;|grep -v MANIFEST.txt >$MYTMPDIR/$$.list
find "$DIR" -type f -name MANIFEST.txt -delete

# This is to cope with people who use spaces in path names
for file in $(cat $MYTMPDIR/$$.list|sed -e 's/ /×/g')
do
    file=$(echo $file|sed -e 's/×/ /g')
    dir=$(dirname "$file")
    name=$(basename "$file")
    if [ ! -f "$dir/MANIFEST.txt" ]; then
    	cat >"$dir/MANIFEST.txt" <<EOF
MD5 fingerprints for this directory contents
--------------------------------------------

These fingerprints are generated in binary mode.
Use 'md5sum -b' or whatever program you use to check they are 
properly stored by their checksums.

EOF
    fi
    (cd "$dir" && md5sum -b "$name" >>MANIFEST.txt)
done
find "$DIR" -type f -name MANIFEST.txt -exec unix2dos -q {} \;

# cleanup 
rm -rf $MYTMPDIR
