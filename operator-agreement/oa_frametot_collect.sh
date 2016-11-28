#!/bin/bash

# Assemble raw tab-delimited operator training set results into one CSV
# Prints to stdout

CRLF=$(printf '\r\n')
LF=$(printf '\n')

# In each raw file:
# - delete four lines of unwanted headers
# - remove empty lines
# - convert Windows-style line endings
# - add a column to identify tracing technician
# - convert from tab-delimited to comma-delimited
for f in "$@"; do
	OPER=`echo $f | sed -E 's/.*-([A-Z]+).txt/\1/'`
	sed -E \
		-e '1,4d' \
		-e '/ROOT/d' \
		-e '/^[[:space:]]*$/d' \
		-e "s/$CRLF/$LF/" \
		-e "s/^/$OPER,/" \
		"$f" \
	| tr '\t' ','
done
