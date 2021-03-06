#!/bin/bash

#PBS -S /bin/bash
#PBS -q default
#PBS -l nodes=1:ppn=6,mem=4000mb
#PBS -M black11@igb.illinois.edu
#PBS -m abe
#PBS -j oe
#PBS -N rz_mctd_2012
#PBS -d /home/a-m/black11/efrhizo/stan
#PBS -t 1-6

module load R/experimental

SHORT_JOBID=`echo $PBS_JOBID | sed 's/\..*//'`
(
	echo "Starting $PBS_JOBNAME"."$SHORT_JOBID on " `date -u`

	echo "Running mix_crop_tube_depth.R for year 2012 session " "$PBS_ARRAYID"
	time Rscript mix_crop_tube_depth.R "$PBS_JOBNAME"."$SHORT_JOBID" "2012" "$PBS_ARRAYID"
) 2>&1 | tee -a "$PBS_JOBNAME"."$SHORT_JOBID".log
