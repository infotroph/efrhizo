#!/bin/bash
# Fit rhizotron model separately for each measurement session
# Use this script for local runs (one day at a time)
# If running on the cluster, use one of the Torque scripts instead.

# Usage: ./mctd_foursurf/sh jobname path/to/output/
# If jobname is missing, defaults to "rz_mctd_" plus the current UNIX time.
# If output directory is missing, defaults to "./stanout"
# BEWARE: Output directory will be overwritten if it exists!

JOBNAME=$1
OUT_DIR=$2

if [ -z $JOBNAME ]; then JOBNAME="rz_mctd_"`date '+%s'`; fi

if [ -z $OUT_DIR ]; then OUT_DIR="stanout"; fi
if [ -e $OUT_DIR ]; then rm -r "$OUT_DIR"; fi
mkdir -p "$OUT_DIR"

YEARS=(2010 2010 2010 2010 2011 2012 2012 2012 2012 2012 2012 2013 2014)
SESSIONS=(1 3 4 5 4 1 2 3 4 5 6 5 2)

for i in ${!YEARS[*]}; do
	Y="${YEARS[$i]}"
	S="${SESSIONS[$i]}"
	RUNID="$JOBNAME"_"$Y"_s"$S"
	(
		echo "Starting $RUNID on " `date -u`
		echo "Running mctd_foursurf.R for year " "$Y" " session " "$S"
		time Rscript stan/mctd_foursurf.R "$RUNID" "$Y" "$S" "$OUT_DIR"

		echo "Extracting fits"
		Rscript stan/extractfits_mctd.R "$OUT_DIR"/"$RUNID".Rdata "$OUT_DIR" "$JOBNAME"
	) 2>&1 | tee -a "$OUT_DIR"/"$RUNID".log
done