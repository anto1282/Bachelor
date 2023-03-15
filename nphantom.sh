#!/bin/bash

#SBATCH --job-name=BACHBOYS
#SBATCH --output=/projects/mjolnir1/people/zpx817/BachAssemblies
#SBATCH --error=/projects/mjolnir1/people/zpx817/errors
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --time=01:00:00
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --mail-type=fail
#SBATCH --mail-user=s203557@dtu.dk
export NXF_CLUSTER_SEED=$(shuf -i 0-16777216 -n 1)

module purge
module load openjdk/11.0.0
module load miniconda singularity/3.8.0 nextflow
srun nextflow run NPhAnToM.nf --IDS SRR13557385 -profile cluster -resume -with-mpi
