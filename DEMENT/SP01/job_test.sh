#!/bin/bash

#SBATCH --comment='GradCatch run test'
#SBATCH --time=0-2:00:00
#SBATCH --mem=50000
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --output=output_%j.txt
#SBATCH --error=error_output_%j.txt
#SBATCH --job-name=dement_parallel
#SBATCH --mail-type=ALL
#SBATCH --mail-user=luciana.chavezrodriguez@wur.nl

##---------- Environment, Operations and job step ----------
module purge
module load 2023
ml Python/3.11.3

# pip install pandas

# source /lustre/nobackup/WUR/ESG/chave013/gradcatch/DEMENT/bin/activate

python /lustre/nobackup/WUR/ESG/chave013/gradcatch/debug/DEMENT_gradcatch/DEMENT/SP01/dement_parallel.py