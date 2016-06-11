#!/bin/bash
# Fit rhizotron model separately for each measurement session
# Use this script for local runs (one day at a time)
# If running on the cluster, use one of the Torque scripts instead.

JOBNAME="rz_mctd"
JOBID=`date +%s`
YEARS=(2010 2010 2010 2010 2011 2012 2012 2012 2012 2012 2012 2013 2014)
SESSIONS=(1 3 4 5 4 1 2 3 4 5 6 5 2)
# YEARS=(2012 2014)
# SESSIONS=(4 2)

for i in ${!YEARS[*]}; do
	Y="${YEARS[$i]}"
	S="${SESSIONS[$i]}"
	RUNID="$JOBNAME"_"$JOBID"_"$Y"_s"$S"
	(echo "Starting $RUNID on " `date -u`) 2>&1 | tee -a "$RUNID".log

	(echo "Running mctd_foursurf.R for year " "$Y" " session " "$S") 2>&1 | tee -a "$RUNID".log
	(time Rscript mctd_foursurf.R "$RUNID" "$Y" "$S") 2>&1 | tee -a "$RUNID".log

	(echo "Extracting fits") 2>&1 | tee -a "$RUNID".log
	(Rscript extractfits_mctd.R "$RUNID".Rdata . "$RUNID") 2>&1 | tee -a "$RUNID".log
done