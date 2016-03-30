#!/bin/bash

# Usage: frametot-collect file1 [file2 file3 ...]
# Cleans up each file given in arguments:
#	* Deletes first 4 header lines ('1,4d'). Add better headers outside of this script.
#	* Deletes lines for individual roots ('/ROOT/d'), which are not used in the analysis.
#	* Deletes lines containing only whitespace ('/^[[:space:]]*$/d'), which are unsightly.
#	* Converts line ends from Windows style to UNIX style ("s/$CRLF/$LF/").

CRLF=$(printf '\r\n')
LF=$(printf '\n')

for f in "$@"; do
	sed \
	-e '1,4d' \
	-e '/ROOT/d' \
	-E -e '/^[[:space:]]*$/d' \
	-e "s/$CRLF/$LF/" "$f"
done
