#!/bin/bash

# ----------------QSUB Parameters----------------- #
#PBS -S /bin/bash
#PBS -q default
#PBS -l nodes=1:ppn=8,mem=7000mb
#PBS -M black11@igb.illinois.edu
#PBS -m abe
#PBS -j oe
#PBS -N rz_mtd
#PBS -d /home/a-m/black11/efrhizo/stan

# ----------------Load Modules-------------------- #
module load R/3.2.3
# ----------------Your Commands------------------- #
SHORT_JOBID=`echo $PBS_JOBID | sed 's/\..*//'`
echo "Starting $PBS_JOBNAME"."$SHORT_JOBID" on `date -u`
echo "mix_tube_depth.R"
time Rscript mix_tube_depth.R "$PBS_JOBNAME"."$SHORT_JOBID"
