#!/bin/bash

#PBS -S /bin/bash
#PBS -q default
#PBS -l nodes=1:ppn=8,mem=7000mb
#PBS -M black11@igb.illinois.edu
#PBS -m abe
#PBS -j oe
#PBS -N rz_mctd
#PBS -d /home/a-m/black11/efrhizo/stan
#PBS -A rhizotron
#PBS -t 0-5

module load R/3.2.0

SHORT_JOBID=`echo $PBS_JOBID | sed 's/\..*//'`
echo "Starting $PBS_JOBNAME"."$SHORT_JOBID" on `date -u`

# Want midseason estimates from each year.
# BUGBUG: the first job in the array seems to generate no output.
# Have emailed Biocluster staff to ask about this,
# but meanwhile let's just add 2010-S3 as a sacrificial session:
# It's not a midseason session, but we don't mind if it unexpectedly runs
years=(2010 2010 2011 2012 2013 2014)
sessions=(3 4 4 4 5 2)
y="${years[$PBS_ARRAYID]}"
s="${sessions[$PBS_ARRAYID]}"

echo "Running mix_crop_tube_depth.R for year " "$y" " session " "$s"
time Rscript mix_crop_tube_depth.R "$PBS_JOBNAME"."$SHORT_JOBID" "$y" "$s"