#!/bin/bash

#SBATCH --job-name=BACHBOYS
#SBATCH --output=/projects/mjolnir1/people/zpx817/
#SBATCH --error=/projects/mjolnir1/people/zpx817/
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --tasks-per-node=1
#SBATCH --mem-per-cpu=4G
#SBATCH --time=01:00:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=s203557@dtu.dk
export NXF_CLUSTER_SEED=$(shuf -i 0-16777216 -n 1)

module purge
module load jdk/11.0.0
module load jdk/1.8.0_291 miniconda singularity/3.8.0 nextflow
srun nextflow run NPhAnToM.nf --IDS SRR13557385 -profile cluster -with-mpi
module purge