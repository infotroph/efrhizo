#!/bin/bash

#PBS -S /bin/bash
#PBS -q default
#PBS -l nodes=1:ppn=8,mem=7000mb
#PBS -M black11@igb.illinois.edu
#PBS -m abe
#PBS -j oe
#PBS -N rz_mctd_2010
#PBS -d /home/a-m/black11/efrhizo/stan
#PBS -t 1-5

module load R/experimental

SHORT_JOBID=`echo $PBS_JOBID | sed 's/\..*//'`
echo "Starting $PBS_JOBNAME"."$SHORT_JOBID" on `date -u`

# There are only four sessions, named 1,3,4,5. 
# I'm lazy and will just let the session 2 script exit with an error when it finds no lines to fit.

echo "Running mix_crop_tube_depth.R for year 2010 " session " "$PBS_ARRAYID
time Rscript mix_crop_tube_depth.R "$PBS_JOBNAME"."$SHORT_JOBID" "2010" "$PBS_ARRAYID"
