#!/bin/bash


# Non-Torque version for test runs on local machine.
# Hand-edit these variables as needed.
JOBNAME="rz_mctd"
JOBID=`date +%s`
YEAR=2014
SESSION=2
N_SUBSAMPLE="" # empty string for no subsampling

(echo "Starting $JOBNAME"."$JOBID on" `date -u`) 2>&1 | tee -a "$JOBNAME"."$JOBID".log
(echo "Fitting mix_crop_tube_depth.R using $N_SUBSAMPLE rows from $YEAR session $SESSION") 2>&1 | tee -a "$JOBNAME"."$JOBID".log
(time Rscript mix_crop_tube_depth.R \
	"$JOBNAME"."$JOBID" \
	"$YEAR" "$SESSION" $N_SUBSAMPLE)  2>&1 | tee -a "$JOBNAME"."$JOBID".log
