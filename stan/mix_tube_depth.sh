#!/bin/bash

# ----------------QSUB Parameters----------------- #
#PBS -S /bin/bash
#PBS -q default
#PBS -l nodes=1:ppn=7,mem=7000mb
#PBS -M black11@igb.illinois.edu
#PBS -m abe
#PBS -j oe
#PBS -N rz_mtd
#PBS -d /home/a-m/black11/efrhizo/stan
#PBS -A rhizotron
# ----------------Load Modules-------------------- #
module load R/3.2.0
# ----------------Your Commands------------------- #
time Rscript mix_tube_depth.R "$PBS_JOBNAME"."$PBS_JOBID"
