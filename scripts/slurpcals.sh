#!/bin/bash

for f in "$@"; do
	echo -n `basename "$f"`
	while read -r; do
		line=`echo "$REPLY" | tr -d '\r'`
		echo -n ", $line"
		#echo
	done < "$f"
	echo
done
