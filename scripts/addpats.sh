#!/bin/bash

# Just wrapping a loop over showpat.py
# assumes images and patfiles are in same directory and have matching names

IMGPATH="/Users/chrisb/rdp-tx/ef2012_t1-t53/"
OUTPATH="/Users/chrisb/UI/efrhizo/tmp/"

FILES=$(find $IMGPATH -name '*.pat' -print0 | xargs -0 basename -s .pat)

for F in $FILES; do
	echo $F
	./scripts/showpat.py "$IMGPATH$F".jpg "$IMGPATH$F".pat "$OUTPATH$F".png
done

