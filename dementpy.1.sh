#!/bin/bash

#SBATCH -p free                	  ## run on the standard partition
#SBATCH -N 1                          ## run on a single node
#SBATCH -n 1                          ## request 1 task (1 CPU)
#SBATCH --cpus-per-task=11            ## number of cores the job needs
#SBATCH -t 15:00:00                    ## 2 hr run time limit
#SBATCH --mem=50000            		  ## requesting 500 MB memory for the job
#SBATCH --mail-type=end               ## send email when the job ends
#SBATCH --mail-user=lucianac@uci.edu  ## use this email address

module load python
python dement_parallel.py